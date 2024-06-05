// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import { Origin } from "@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/OApp.sol";
import { SendParam, MessagingFee, MessagingReceipt, OFTReceipt } from "@layerzerolabs/lz-evm-oapp-v2/contracts/oft/interfaces/IOFT.sol";
import { OFT } from "@layerzerolabs/lz-evm-oapp-v2/contracts/oft/OFT.sol";
import { OFTMsgCodec } from "@layerzerolabs/lz-evm-oapp-v2/contracts/oft/libs/OFTMsgCodec.sol";

import { IERC20MintableAndBurnable } from "../interfaces/IERC20MintableAndBurnable.sol";

import "../libraries/ConstantsLib.sol";
import { SafeTransferLib } from "../libraries/SafeTransferLib.sol";
import { PercentageMathLib } from "../libraries/PercentageMathLib.sol";
import { EventsLib } from "../libraries/EventsLib.sol";
import { ErrorsLib } from "../libraries/ErrorsLib.sol";


/// @title BridgeableToken
/// @author Murphy Labs
/// @custom:contact security@murphylabs.io
/// @notice Contract that using OFT to bridge tokens between chains.
contract BridgeableToken is OFT, ReentrancyGuard {
    using SafeTransferLib for IERC20;
    using PercentageMathLib for uint256;
    using OFTMsgCodec for bytes;
    using OFTMsgCodec for bytes32;

    struct ConfigParams {
        uint256 mintDailyLimit;
        uint256 globalMintLimit;
        uint256 burnDailyLimit;
        uint256 globalBurnLimit;
        address feesRecipient;
        uint16 feesRate;
        bool isIsolateMode;
    }

    //-------------------------------------------
    // Storage
    //-------------------------------------------

    /// @notice The innerToken that can be minted and burned.
    IERC20 private immutable innerToken;
    /// @notice Track the amount difference between minted and burned tokens.
    /// @dev If amount < 0, it means that more tokens were burned than minted.
    int256 private netMintedAmount;
    /// @notice Limit the bridge to mint/burn tokens.
    /// @dev If true, the amount of minted tokens must be greater than the burned tokens.
    /// if set to True when the `netMintedAmount` is negative, no more tokens can be bridge from this chain.
    bool private isIsolateMode;
    /// @notice The fees rate in basic point.
    uint16 private feesRate;
    /// @notice The fees recipient address.
    address private feesRecipient;
    /// @notice The daily limit allow to bridge TO this chain.
    uint256 private mintDailyLimit;
    /// @notice The global limit allow to bridge TO this chain.
    uint256 private globalMintLimit;
    /// @notice The daily limit allow to bridge FROM this chain.
    uint256 private burnDailyLimit;
    /// @notice The global limit allow to bridge FROM this chain.
    int256 private globalBurnLimit;
    /// @notice Track the daily usage of minted tokens.
    mapping(uint256 day => uint256 usage) private mintDailyUsage;
    /// @notice Track the daily usage of burned tokens.
    mapping(uint256 day => uint256 usage) private burnDailyUsage;

    //-------------------------------------------
    // Constructor
    //-------------------------------------------

    /// @notice Constructor for the OFT contract.
    /// @param _name The name of the OFT.
    /// @param _symbol The symbol of the OFT.
    /// @param _innerToken The innerToken address.
    /// @param _lzEndpoint The LayerZero endpoint address.
    /// @param _delegate The delegate capable of making OApp configurations inside of the endpoint.
    /// @param _config The configuration parameters for the OFT.
    constructor(
        string memory _name,
        string memory _symbol,
        address _innerToken,
        address _lzEndpoint,
        address _delegate,
        ConfigParams memory _config
    ) Ownable(_delegate) OFT(_name, _symbol, _lzEndpoint, _delegate) {
        if (_innerToken == address(0)) revert ErrorsLib.AddressZero();
        innerToken = IERC20(_innerToken);
        _setFeesRate(_config.feesRate);
        _setMintDailyLimit(_config.mintDailyLimit);
        _setGlobalMintLimit(_config.globalMintLimit);
        _setBurnDailyLimit(_config.burnDailyLimit);
        _setGlobalBurnLimit(_config.globalBurnLimit);
        _setIsolateMode(_config.isIsolateMode);
        _setFeesRecipient(_config.feesRecipient);
    }

    //-------------------------------------------
    // External functions
    //-------------------------------------------

    /// @notice Executes the send operation.
    /// @param _sendParam The parameters for the send operation.
    /// @param _fee The calculated fees for the send() operation.
    ///      - nativeFee: The native fees.
    ///      - lzTokenFee: The lzToken fees.
    /// @param _refundAddress The address to receive any excess funds.
    /// @return msgReceipt The receipt for the send operation.
    /// @return oftReceipt The OFT receipt information.
    ///
    /// @dev MessagingReceipt: LayerZero msg receipt
    ///  - guid: The unique identifier for the sent message.
    ///  - nonce: The nonce of the sent message.
    ///  - fees: The LayerZero fees incurred for the message.
    function send(
        SendParam calldata _sendParam,
        MessagingFee calldata _fee,
        address _refundAddress
    )
        external
        payable
        override
        nonReentrant
        returns (MessagingReceipt memory msgReceipt, OFTReceipt memory oftReceipt)
    {
        bool isInnerTokenBurned = abi.decode(_sendParam.composeMsg, (bool));

        (uint256 amountSentLD, uint256 amountReceived) = _debit(
            isInnerTokenBurned,
            _sendParam.amountLD,
            _sendParam.minAmountLD,
            _sendParam.dstEid
        );

        // @dev Builds the options and OFT message to quote in the endpoint.
        (bytes memory message, bytes memory options) = _buildMsgAndOptions(_sendParam, amountReceived);
        // @dev Sends the message to the LayerZero endpoint and returns the LayerZero msg receipt.
        msgReceipt = _lzSend(_sendParam.dstEid, message, options, _fee, _refundAddress);
        // @dev Formulate the OFT receipt.
        oftReceipt = OFTReceipt(amountSentLD, amountReceived);

        emit EventsLib.OFTSent(
            msgReceipt.guid,
            _sendParam.dstEid,
            msg.sender,
            isInnerTokenBurned,
            amountSentLD,
            amountReceived
        );
    }

    /// @notice Allow user to swap OFT token to innerToken if the amount is within the mint limit.
    /// @dev when the user swap OFT token to innerToken, the OFT token will be burned and the innerToken will be minted.
    /// @param _amount The amount of OFT token to swap.
    function swapLzTokenToInnerToken(uint256 _amount) external nonReentrant {
        _burn(msg.sender, _amount);
        uint256 innerTokenAmountToMint = _calculateInnerTokenAmountToMint(_amount);
        if (innerTokenAmountToMint != _amount) revert ErrorsLib.MintLimitExceeded();

        uint256 feeAmount = innerTokenAmountToMint.percentMul(feesRate);
        if (feeAmount > 0) {
            IERC20MintableAndBurnable(address(innerToken)).mint(feesRecipient, feeAmount);
        }
        IERC20MintableAndBurnable(address(innerToken)).mint(msg.sender, innerTokenAmountToMint - feeAmount);
    }

    //-------------------------------------------
    // External view functions
    //-------------------------------------------

    /// @notice The innerToken address.
    function getInnerToken() external view returns (address) {
        return address(innerToken);
    }

    /// @notice The mintable daily limit for the token.
    function getMintDailyLimit() external view returns (uint256) {
        return mintDailyLimit;
    }

    /// @notice The burnable daily limit for the token.
    function getBurnDailyLimit() external view returns (uint256) {
        return burnDailyLimit;
    }

    /// @notice The global mint limit for the token.
    function getGlobalMintLimit() external view returns (uint256) {
        return globalMintLimit;
    }

    /// @notice The burnable daily limit for the token.
    function getGlobalBurnLimit() external view returns (uint256) {
        return uint256(-globalBurnLimit);
    }

    /// @notice Whether the `isIsolateMode` is enabled.
    function getIsIsolateMode() external view returns (bool) {
        return isIsolateMode;
    }

    /// @notice Retrieves the minted amount.
    /// @dev If amount < 0, it means that more tokens were burned than minted.
    function getNetMintedAmount() external view returns (int256) {
        return netMintedAmount;
    }

    /// @notice The fees recipient address.
    /// @dev The recipient receives the innerToken fees.
    function getFeesRecipient() external view returns (address) {
        return feesRecipient;
    }

    /// @notice The fees rate in basic point.
    function getFeesRate() external view returns (uint16) {
        return feesRate;
    }


    /// @notice Retrieves the current daily usage of minted tokens.
    function getCurrentMintDailyUsage() external view returns (uint256) {
        uint256 day = block.timestamp / DAY_IN_SECONDS;
        return mintDailyUsage[day];
    }

    /// @notice Retrieves the current daily usage of burned tokens.
    function getCurrentBurnDailyUsage() external view returns (uint256) {
        uint256 day = block.timestamp / DAY_IN_SECONDS;
        return burnDailyUsage[day];
    }

    //-------------------------------------------
    // OnlyOwner functions
    //-------------------------------------------

    /// @notice Toggle `isIsolateMode` to enable/disable the isolation mode.
    function toggleIsolateMode() external onlyOwner {
        _setIsolateMode(!isIsolateMode);
    }

    /// @notice Sets `_newFeesRate` as `feesRate` of the fees applied on innerToken mint.
    /// @dev The fees rate in basic point with a maximum of 10% (10_00 in bp)
    /// @param _newFeesRate The new fees rate in basic point.
    function setFeesRate(uint16 _newFeesRate) external onlyOwner {
        _setFeesRate(_newFeesRate);
    }

    /// @notice Sets `_mintDailyLimit` as `mintDailyLimit` of daily amount of innerToken mintable.
    /// @param _mintDailyLimit The daily limit of innerToken mintable.
    function setMintDailyLimit(uint256 _mintDailyLimit) external onlyOwner {
        _setMintDailyLimit(_mintDailyLimit);
    }

    /// @notice Sets `_globalMintLimit` as `globalMintLimit` of max amount of innerToken mintable.
    /// @param _globalMintLimit The max limit of innerToken mintable.
    function setGlobalMintLimit(uint256 _globalMintLimit) external onlyOwner {
        _setGlobalMintLimit(_globalMintLimit);
    }

    /// @notice Sets `_burnDailyLimit` as `burnDailyLimit` of daily amount of innerToken burnable.
    /// @param _burnDailyLimit The daily limit of innerToken burnable.
    function setBurnDailyLimit(uint256 _burnDailyLimit) external onlyOwner {
        _setBurnDailyLimit(_burnDailyLimit);
    }

    /// @notice Sets `_globalBurnLimit` as `globalBurnLimit` of max amount of innerToken burnable.
    /// @param _globalBurnLimit The max limit of innerToken burnable.
    function setGlobalBurnLimit(uint256 _globalBurnLimit) external onlyOwner {
        _setGlobalBurnLimit(_globalBurnLimit);
    }

    /// @notice Sets `_newFeesRecipient` as `feesRecipient` of the fees.
    /// @param _newFeesRecipient The new fees recipient address.
    function setFeesRecipient(address _newFeesRecipient) external onlyOwner {
        _setFeesRecipient(_newFeesRecipient);
    }

    //-------------------------------------------
    // Internal functions
    //-------------------------------------------

    /// @dev Internal function to handle the receive on the LayerZero endpoint.
    /// @param _origin The origin information.
    ///  - srcEid: The source chain endpoint ID.
    ///  - sender: The sender address from the src chain.
    ///  - nonce: The nonce of the LayerZero message.
    /// @param _guid The unique identifier for the received LayerZero message.
    /// @param _message The encoded message.
    /// @dev _executor The address of the executor.
    /// @dev _extraData Additional data.
    function _lzReceive(
        Origin calldata _origin,
        bytes32 _guid,
        bytes calldata _message,
        address /*_executor*/, // @dev unused in the default implementation.
        bytes calldata /*_extraData*/ // @dev unused in the default implementation.
    ) internal virtual override {
        // @dev The src sending chain doesnt know the address length on this chain (potentially non-evm)
        // Thus everything is bytes32() encoded in flight.
        address toAddress = _message.sendTo().bytes32ToAddress();

        /// @dev Extract if the tokens burn from the original chain was the innerToken or the OFT token. If true, fees could be applied.
        (, bool feeApplicable) = abi.decode(_message.composeMsg(), (bytes32, bool));

        // @dev Credit the amountLD to the recipient and return the ACTUAL amount the recipient received in local decimals
        (uint256 amountReceived, uint256 oftReceived, uint256 feeAmount) = _credit(
            toAddress,
            _toLD(_message.amountSD()),
            _origin.srcEid,
            feeApplicable
        );

        emit EventsLib.OFTReceived(_guid, _origin.srcEid, toAddress, amountReceived, oftReceived, feeAmount);
    }

    //-------------------------------------------
    // Private functions
    //-------------------------------------------

    /// @dev Burns tokens from the sender's specified balance.
    /// @param _isInnerTokenToBurn the flag to burn the innerToken or the OFT token from the caller.
    /// @param _amountLD The amount of tokens to send in local decimals.
    /// @param _minAmountLD The minimum amount to send in local decimals.
    /// @param _dstEid The destination chain ID.
    /// @return amountSentLD The amount sent in local decimals.
    /// @return amountReceived The amount received in local decimals on the remote.
    function _debit(
        bool _isInnerTokenToBurn,
        uint256 _amountLD,
        uint256 _minAmountLD,
        uint32 _dstEid
    ) private returns (uint256 amountSentLD, uint256 amountReceived) {
        (amountSentLD, amountReceived) = _debitView(_amountLD, _minAmountLD, _dstEid);

        if(_isInnerTokenToBurn){
            /// @dev Assert that the amount to burn DO NOT exceed the daily limit.
            uint256 day = block.timestamp / DAY_IN_SECONDS;
            uint256 dailyUsage = burnDailyUsage[day];
            if (dailyUsage + amountReceived > burnDailyLimit) revert ErrorsLib.BurnDailyLimitReached();

            burnDailyUsage[day] += amountReceived;
            netMintedAmount -= int256(amountReceived);
            
            if (isIsolateMode) {
                /// @dev Assert that the final netMintedAmount is greater than 0.
                if (netMintedAmount < 0) revert ErrorsLib.IsolateModeLimitReach();
            } else {
                /// @dev Assert that the final netMintedAmount is greater than the globalBurnLimit.
                if (netMintedAmount < globalBurnLimit) revert ErrorsLib.GlobalBurnLimitReached();
            }
            IERC20MintableAndBurnable(address(innerToken)).burn(msg.sender, amountSentLD);
        } else {
            _burn(msg.sender, amountSentLD);
        }
    }

    /// @notice Credits tokens to the specified address.
    /// @param _to The address to credit the tokens to.
    /// @param _amountLD The amount of tokens to credit in local decimals.
    /// @dev _srcEid The source chain ID.
    /// @param _isFeeApplicable The flag to apply fees or not.
    /// @return amountReceived The amount of tokens ACTUALLY received in local decimals.
    function _credit(
        address _to,
        uint256 _amountLD,
        uint32, //_srcEid,
        bool _isFeeApplicable
    ) private returns (uint256 amountReceived, uint256 oftReceived, uint256 feeAmount) {
        (amountReceived, feeAmount) = _creditInnerToken(_to, _amountLD, _isFeeApplicable);

        oftReceived = _amountLD - amountReceived - feeAmount;
        /// If OftReceived we must be credit to the user OFT tokens to match the total amount he must be credited.
        if (oftReceived > 0) {
            _mint(_to, oftReceived);
        }
    }

    /// @notice Calculates and credit inner tokens to `_to` address and the `feesRecipient`.
    /// @param _to The address to credit the tokens to.
    /// @param _amountLD The amount of token expected to be credited.
    /// @return amountReceived The amount of inner token minted.
    /// @return feeAmount The amount of fees token minted.
    function _creditInnerToken(
        address _to,
        uint256 _amountLD,
        bool _isFeeApplicable
    ) private returns (uint256 amountReceived, uint256 feeAmount) {
        amountReceived = _calculateInnerTokenAmountToMint(_amountLD);
        if (amountReceived > 0) {
            uint256 day = block.timestamp / DAY_IN_SECONDS;
            mintDailyUsage[day] += amountReceived;
            netMintedAmount += int256(amountReceived);
            if (_isFeeApplicable) {
                if (feesRate > 0) {
                    feeAmount = amountReceived.percentMul(feesRate);
                    amountReceived -= feeAmount;
                    IERC20MintableAndBurnable(address(innerToken)).mint(feesRecipient, feeAmount);
                }
            }
            IERC20MintableAndBurnable(address(innerToken)).mint(_to, amountReceived);
        }
        return (amountReceived, feeAmount);
    }

    /// @notice Calculates the amount of innerToken to mint.
    /// @dev The amount of innerToken that can be minted regarding the limits.
    /// @param _amountLD The amount of token expected to be minted.
    /// @return innerTokenAmountToMint The total amount of innerToken to mint.
    function _calculateInnerTokenAmountToMint(uint256 _amountLD) private view returns (uint256 innerTokenAmountToMint) {
        innerTokenAmountToMint = int256(_amountLD) + netMintedAmount > int256(globalMintLimit)
            ? globalMintLimit - uint256(netMintedAmount)
            : _amountLD;
        uint256 day = block.timestamp / DAY_IN_SECONDS;
        uint256 dailyUsage = mintDailyUsage[day];
        if (dailyUsage + innerTokenAmountToMint > mintDailyLimit) {
            innerTokenAmountToMint = mintDailyLimit > dailyUsage ? mintDailyLimit - dailyUsage : 0;
        }
    }

    /// @notice Sets the `isIsolateMode` flag.
    /// @param _isIsolateMode The new value for the `isIsolateMode` flag.
    function _setIsolateMode(bool _isIsolateMode) private {
        isIsolateMode = _isIsolateMode;
        emit EventsLib.IsolateModeToggled(_isIsolateMode);
    }

    /// @notice Sets `_newMintDailyLimit` as `mintDailyLimit` of daily amount of innerToken mintable.
    /// @param _newMintDailyLimit The daily limit of innerToken mintable.
    function _setMintDailyLimit(uint256 _newMintDailyLimit) private {
        mintDailyLimit = _newMintDailyLimit;
        emit EventsLib.MintableDailyLimitSet(_newMintDailyLimit);
    }

    /// @notice Sets `_newGlobalMintLimit` as `globalMintLimit` of max amount of innerToken mintable.
    /// @param _newGlobalMintLimit The max limit of innerToken mintable.
    function _setGlobalMintLimit(uint256 _newGlobalMintLimit) private {
        if (_newGlobalMintLimit > uint256(type(int256).max)) {
            revert ErrorsLib.GlobalMintLimitCantExceedMaxInt256();
        }
        globalMintLimit = _newGlobalMintLimit;
        emit EventsLib.GlobalMintLimitSet(_newGlobalMintLimit);
    }

    /// @notice Sets `_newBurnDailyLimit` as `burnDailyLimit` of daily amount of innerToken burnable.
    /// @param _newBurnDailyLimit The daily limit of innerToken burnable.
    function _setBurnDailyLimit(uint256 _newBurnDailyLimit) private {
        burnDailyLimit = _newBurnDailyLimit;
        emit EventsLib.BurnableDailyLimitSet(_newBurnDailyLimit);
    }

    /// @notice Sets `_newBurnDailyLimit` as `globalBurnLimit` of max amount of innerToken burnable.
    /// @param _newGlobalBurnLimit The max limit of innerToken burnable.
    function _setGlobalBurnLimit(uint256 _newGlobalBurnLimit) private {
        if (_newGlobalBurnLimit > uint256(type(int256).min)) {
            revert ErrorsLib.GlobalBurnLimitCantExceedMinInt256();
        }
        globalBurnLimit = -int256(_newGlobalBurnLimit);
        emit EventsLib.GlobalBurnLimitSet(_newGlobalBurnLimit);
    }

    /// @notice Sets `_newFeesRate` as `feesRate` of the fees applied on innerToken mint.
    /// @param _newFeesRate The new fees rate in basic point.
    function _setFeesRate(uint16 _newFeesRate) private {
        if (_newFeesRate > MAX_FEE) revert ErrorsLib.MaxFeesRateExceeded();
        feesRate = _newFeesRate;
        emit EventsLib.FeesRateSet(_newFeesRate);
    }

    /// @dev Sets `_newFeesRecipient` as `feesRecipient` of the fees.
    /// @param _newFeesRecipient The new fees recipient address.
    function _setFeesRecipient(address _newFeesRecipient) private {
        if (_newFeesRecipient == address(0)) revert ErrorsLib.AddressZero();
        feesRecipient = _newFeesRecipient;
        emit EventsLib.FeesRecipientSet(_newFeesRecipient);
    }
}
