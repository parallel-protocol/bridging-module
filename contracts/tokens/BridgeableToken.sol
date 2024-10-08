// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import { Pausable } from "@openzeppelin/contracts/utils/Pausable.sol";

import { Origin } from "@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/OApp.sol";
import { SendParam, MessagingFee, MessagingReceipt, OFTReceipt } from "@layerzerolabs/lz-evm-oapp-v2/contracts/oft/interfaces/IOFT.sol";
import { OFT } from "@layerzerolabs/lz-evm-oapp-v2/contracts/oft/OFT.sol";
import { OFTMsgCodec } from "@layerzerolabs/lz-evm-oapp-v2/contracts/oft/libs/OFTMsgCodec.sol";

import { IERC20MintableAndBurnable } from "../interfaces/IERC20MintableAndBurnable.sol";

import "../libraries/ConstantsLib.sol";

import { PercentageMathLib } from "../libraries/PercentageMathLib.sol";
import { EventsLib } from "../libraries/EventsLib.sol";
import { ErrorsLib } from "../libraries/ErrorsLib.sol";
import { MathLib } from "../libraries/MathLib.sol";

/// @title BridgeableToken
/// @author Cooper Labs
/// @custom:contact security@cooperlabs.xyz
/// @notice Contract that using OFT to bridge tokens between chains.
contract BridgeableToken is OFT, ReentrancyGuard, Pausable {
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

    /// @notice The principalToken that can be minted and burned.
    IERC20 private immutable principalToken;
    /// @notice Limit the bridge to burn more principal token than it has minted.
    /// @dev If true, the bridge can't burn more tokens than it had minted (netMintedAmount > 0).
    bool private isIsolateMode;
    /// @notice The fees recipient address.
    address private feesRecipient;
    /// @notice The fees rate in basic point.
    uint16 private feesRate;
    /// @notice Track the diff amount between principal tokens minted and burned.
    /// @dev If amount < 0, it means that more tokens were burned than minted.
    int256 private netMintedAmount;
    /// @notice The daily limit of PrincipalToken allowed to bridge TO this chain.
    uint256 private mintDailyLimit;
    /// @notice The global limit of PrincipalToken allowed to bridge TO this chain.
    uint256 private globalMintLimit;
    /// @notice The daily limit of PrincipalToken allowed to bridge FROM this chain.
    uint256 private burnDailyLimit;
    /// @notice The global limit of PrincipalToken allowed to bridge FROM this chain.
    int256 private globalBurnLimit;
    /// @notice Track the daily usage of PrincipalToken minted.
    mapping(uint256 day => uint256 usage) private mintDailyUsage;
    /// @notice Track the daily usage of PrincipalToken burned.
    mapping(uint256 day => uint256 usage) private burnDailyUsage;

    //-------------------------------------------
    // Constructor
    //-------------------------------------------

    /// @notice Constructor for the OFT contract.
    /// @param _name The name of the OFT.
    /// @param _symbol The symbol of the OFT.
    /// @param _principalToken The principalToken address.
    /// @param _lzEndpoint The LayerZero endpoint address.
    /// @param _delegate The delegate capable of making OApp configurations inside of the endpoint.
    /// @param _config The configuration parameters for the OFT.
    constructor(
        string memory _name,
        string memory _symbol,
        address _principalToken,
        address _lzEndpoint,
        address _delegate,
        ConfigParams memory _config
    ) Ownable(_delegate) OFT(_name, _symbol, _lzEndpoint, _delegate) {
        if (_principalToken == address(0)) revert ErrorsLib.AddressZero();
        principalToken = IERC20(_principalToken);
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
        whenNotPaused
        returns (MessagingReceipt memory msgReceipt, OFTReceipt memory oftReceipt)
    {
        if (_sendParam.composeMsg.length != 32) revert ErrorsLib.InvalidMsgLength();

        bool isPrincipalTokenBurned = abi.decode(_sendParam.composeMsg, (bool));

        (uint256 amountSent, uint256 amountReceived) = _debit(
            isPrincipalTokenBurned,
            _sendParam.amountLD,
            _sendParam.minAmountLD,
            _sendParam.dstEid
        );

        // @dev Builds the options and OFT message to quote in the endpoint.
        (bytes memory message, bytes memory options) = _buildMsgAndOptions(_sendParam, amountReceived);
        // @dev Sends the message to the LayerZero endpoint and returns the LayerZero msg receipt.
        msgReceipt = _lzSend(_sendParam.dstEid, message, options, _fee, _refundAddress);
        // @dev Formulate the OFT receipt.
        oftReceipt = OFTReceipt(amountSent, amountReceived);

        emit EventsLib.BridgeableTokenSent(
            msgReceipt.guid,
            _sendParam.dstEid,
            msg.sender,
            _sendParam.to.bytes32ToAddress(),
            _fee.nativeFee,
            isPrincipalTokenBurned,
            amountSent,
            amountReceived
        );
    }

    /// @notice Allow user to swap OFT token to principalToken if the amount is within the mint limit.
    /// @dev when the user swap OFT token to principalToken, the OFT token will be burned and the principalToken will be
    /// minted.
    /// @param _amount The amount of OFT token to swap.
    function swapLzTokenToPrincipalToken(uint256 _amount) external nonReentrant whenNotPaused {
        _burn(msg.sender, _amount);

        uint256 principalTokenAmountToMint = _calculatePrincipalTokenAmountToMint(_amount);

        if (principalTokenAmountToMint != _amount) revert ErrorsLib.MintLimitExceeded();

        _updateStorageOnMint(principalTokenAmountToMint);

        uint256 feeAmount = principalTokenAmountToMint.percentMul(feesRate);
        principalTokenAmountToMint = principalTokenAmountToMint - feeAmount;

        emit EventsLib.OFTSwapped(msg.sender, _amount, principalTokenAmountToMint, feeAmount);

        if (feeAmount > 0) {
            IERC20MintableAndBurnable(address(principalToken)).mint(feesRecipient, feeAmount);
        }
        IERC20MintableAndBurnable(address(principalToken)).mint(msg.sender, principalTokenAmountToMint);
    }

    //-------------------------------------------
    // External view functions
    //-------------------------------------------

    /// @notice The principalToken address.
    function getPrincipalToken() external view returns (address) {
        return address(principalToken);
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
        return uint256(MathLib.abs(globalBurnLimit));
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
    /// @dev The recipient receives the principalToken fees.
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

    /// @notice Retrieves the MAX amount of PrincipalToken mintable regarding limits.
    function getMaxMintableAmount() external view returns (uint256) {
        if (netMintedAmount >= int256(globalMintLimit)) return 0;
        uint256 max = uint256(int256(globalMintLimit) - netMintedAmount);
        uint256 day = block.timestamp / DAY_IN_SECONDS;
        uint256 dailyUsage = mintDailyUsage[day];
        if (dailyUsage + max > mintDailyLimit) {
            max = mintDailyLimit > dailyUsage ? mintDailyLimit - dailyUsage : 0;
        }
        return max;
    }

    /// @notice Retrieves the MAX amount of PrincipalToken burnable regarding limits.
    function getMaxBurnableAmount() external view returns (uint256) {
        if (isIsolateMode && netMintedAmount < 0) return 0;
        if (netMintedAmount <= globalBurnLimit) return 0;
        uint256 max = MathLib.abs(globalBurnLimit - netMintedAmount);
        uint256 day = block.timestamp / DAY_IN_SECONDS;
        uint256 dailyUsage = burnDailyUsage[day];
        if (dailyUsage + max > burnDailyLimit) {
            max = burnDailyLimit > dailyUsage ? burnDailyLimit - dailyUsage : 0;
        }
        return max;
    }

    //-------------------------------------------
    // OnlyOwner functions
    //-------------------------------------------

    /// @notice Toggle `isIsolateMode` to enable/disable the isolation mode.
    function toggleIsolateMode() external onlyOwner {
        _setIsolateMode(!isIsolateMode);
    }

    /// @notice Sets `_newFeesRate` as `feesRate` of the fees applied on principalToken mint.
    /// @dev The fees rate in basic point with a maximum of 10% (10_00 in bp)
    /// @param _newFeesRate The new fees rate in basic point.
    function setFeesRate(uint16 _newFeesRate) external onlyOwner {
        _setFeesRate(_newFeesRate);
    }

    /// @notice Sets `_mintDailyLimit` as `mintDailyLimit` of daily amount of principalToken mintable.
    /// @param _mintDailyLimit The daily limit of principalToken mintable.
    function setMintDailyLimit(uint256 _mintDailyLimit) external onlyOwner {
        _setMintDailyLimit(_mintDailyLimit);
    }

    /// @notice Sets `_globalMintLimit` as `globalMintLimit` of max amount of principalToken mintable.
    /// @param _globalMintLimit The max limit of principalToken mintable.
    function setGlobalMintLimit(uint256 _globalMintLimit) external onlyOwner {
        _setGlobalMintLimit(_globalMintLimit);
    }

    /// @notice Sets `_burnDailyLimit` as `burnDailyLimit` of daily amount of principalToken burnable.
    /// @param _burnDailyLimit The daily limit of principalToken burnable.
    function setBurnDailyLimit(uint256 _burnDailyLimit) external onlyOwner {
        _setBurnDailyLimit(_burnDailyLimit);
    }

    /// @notice Sets `_globalBurnLimit` as `globalBurnLimit` of max amount of principalToken burnable.
    /// @param _globalBurnLimit The max limit of principalToken burnable.
    function setGlobalBurnLimit(uint256 _globalBurnLimit) external onlyOwner {
        _setGlobalBurnLimit(_globalBurnLimit);
    }

    /// @notice Sets `_newFeesRecipient` as `feesRecipient` of the fees.
    /// @param _newFeesRecipient The new fees recipient address.
    function setFeesRecipient(address _newFeesRecipient) external onlyOwner {
        _setFeesRecipient(_newFeesRecipient);
    }

    /// @notice Allow owner to pause the contract
    /// @dev This function can only be called by the owner
    function pause() external onlyOwner {
        _pause();
    }

    /// @notice Allow owner to unpause the contract
    /// @dev This function can only be called by the owner
    function unpause() external onlyOwner {
        _unpause();
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
    ) internal virtual override nonReentrant {
        // @dev The src sending chain doesnt know the address length on this chain (potentially non-evm)
        // Thus everything is bytes32() encoded in flight.
        address to = _message.sendTo().bytes32ToAddress();

        /// @dev Extract from message if the tokens burned from the original chain
        /// was the principalToken or the OFT token. If true, fees could be applied.
        (, bool feeApplicable) = abi.decode(_message.composeMsg(), (bytes32, bool));

        // @dev Credit the amountLD to the recipient and return the ACTUAL amount the recipient received in local
        // decimals
        (uint256 amountReceived, uint256 oftReceived, uint256 feesAmount) = _credit(
            to,
            _toLD(_message.amountSD()),
            _origin.srcEid,
            feeApplicable
        );

        emit EventsLib.BridgeableTokenReceived(
            _guid,
            _origin.srcEid,
            _origin.sender.bytes32ToAddress(),
            to,
            amountReceived,
            oftReceived,
            feesAmount
        );
    }

    //-------------------------------------------
    // Private functions
    //-------------------------------------------

    /// @dev Burns tokens from the sender's specified balance.
    /// @param _isPrincipalTokenToBurn the flag to burn the principalToken or the OFT token from the caller.
    /// @param _amountLD The amount of tokens to send in local decimals.
    /// @param _minAmountLD The minimum amount to send in local decimals.
    /// @param _dstEid The destination chain ID.
    /// @return amountSentLD The amount sent in local decimals.
    /// @return amountReceived The amount received in local decimals on the remote.
    function _debit(
        bool _isPrincipalTokenToBurn,
        uint256 _amountLD,
        uint256 _minAmountLD,
        uint32 _dstEid
    ) private returns (uint256 amountSentLD, uint256 amountReceived) {
        (amountSentLD, amountReceived) = _debitView(_amountLD, _minAmountLD, _dstEid);

        if (_isPrincipalTokenToBurn) {
            /// @dev Assert that the amount to burn DO NOT exceed the daily limit.
            _updateStorageOnBurn(amountSentLD);

            if (isIsolateMode) {
                /// @dev Assert that the final netMintedAmount is greater than 0.
                if (netMintedAmount < 0) revert ErrorsLib.IsolateModeLimitReach();
            } else {
                /// @dev Assert that the final netMintedAmount is greater than the globalBurnLimit.
                if (netMintedAmount < globalBurnLimit) revert ErrorsLib.GlobalBurnLimitReached();
            }
            IERC20MintableAndBurnable(address(principalToken)).burn(msg.sender, amountSentLD);
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
        (amountReceived, feeAmount) = _creditPrincipalToken(_to, _amountLD, _isFeeApplicable);

        oftReceived = _amountLD - amountReceived - feeAmount;
        /// If OftReceived > 0 we must be credit to the user OFT tokens to match the total amount he must be credited.
        if (oftReceived > 0) {
            _mint(_to, oftReceived);
        }
    }

    /// @notice Calculates and credit principal tokens to `_to` address and the `feesRecipient`.
    /// @param _to The address to credit the tokens to.
    /// @param _amountLD The amount of token expected to be credited.
    /// @return amountReceived The amount of principal token minted.
    /// @return feeAmount The amount of fees token minted.
    function _creditPrincipalToken(
        address _to,
        uint256 _amountLD,
        bool _isFeeApplicable
    ) private returns (uint256 amountReceived, uint256 feeAmount) {
        amountReceived = _calculatePrincipalTokenAmountToMint(_amountLD);
        if (amountReceived > 0) {
            _updateStorageOnMint(amountReceived);
            if (_isFeeApplicable) {
                if (feesRate > 0) {
                    feeAmount = amountReceived.percentMul(feesRate);
                    amountReceived -= feeAmount;
                    IERC20MintableAndBurnable(address(principalToken)).mint(feesRecipient, feeAmount);
                }
            }
            IERC20MintableAndBurnable(address(principalToken)).mint(_to, amountReceived);
        }
    }

    /// @notice Updates the storage when minting new PrincipalTokens.
    /// @param _amountMinted The amount of PrincipalTokens minted.
    function _updateStorageOnMint(uint256 _amountMinted) private {
        uint256 day = block.timestamp / DAY_IN_SECONDS;
        mintDailyUsage[day] += _amountMinted;
        netMintedAmount += int256(_amountMinted);
    }

    /// @notice Updates the storage when burning PrincipalTokens.
    /// @param _amountBurned The amount of PrincipalTokens burned.
    function _updateStorageOnBurn(uint256 _amountBurned) private {
        uint256 day = block.timestamp / DAY_IN_SECONDS;
        if (burnDailyUsage[day] + _amountBurned > burnDailyLimit) revert ErrorsLib.BurnDailyLimitReached();
        burnDailyUsage[day] += _amountBurned;
        netMintedAmount -= int256(_amountBurned);
    }

    /// @notice Calculates the amount of principalToken to mint.
    /// @dev The amount of principalToken that can be minted regarding the limits.
    /// @param _amountLD The amount of token expected to be minted.
    /// @return principalTokenAmountToMint The total amount of principalToken to mint.
    function _calculatePrincipalTokenAmountToMint(
        uint256 _amountLD
    ) private view returns (uint256 principalTokenAmountToMint) {
        if (netMintedAmount >= int256(globalMintLimit)) return 0;
        principalTokenAmountToMint = int256(_amountLD) + netMintedAmount > int256(globalMintLimit)
            ? globalMintLimit - uint256(netMintedAmount)
            : _amountLD;
        uint256 day = block.timestamp / DAY_IN_SECONDS;
        uint256 dailyUsage = mintDailyUsage[day];
        if (dailyUsage + principalTokenAmountToMint > mintDailyLimit) {
            principalTokenAmountToMint = mintDailyLimit > dailyUsage ? mintDailyLimit - dailyUsage : 0;
        }
    }

    /// @notice Sets the `isIsolateMode` flag.
    /// @param _isIsolateMode The new value for the `isIsolateMode` flag.
    function _setIsolateMode(bool _isIsolateMode) private {
        isIsolateMode = _isIsolateMode;
        emit EventsLib.IsolateModeToggled(_isIsolateMode);
    }

    /// @notice Sets `_newMintDailyLimit` as `mintDailyLimit` of daily amount of principalToken mintable.
    /// @param _newMintDailyLimit The daily limit of principalToken mintable.
    function _setMintDailyLimit(uint256 _newMintDailyLimit) private {
        mintDailyLimit = _newMintDailyLimit;
        emit EventsLib.MintableDailyLimitSet(_newMintDailyLimit);
    }

    /// @notice Sets `_newGlobalMintLimit` as `globalMintLimit` of max amount of principalToken mintable.
    /// @param _newGlobalMintLimit The max limit of principalToken mintable.
    function _setGlobalMintLimit(uint256 _newGlobalMintLimit) private {
        if (_newGlobalMintLimit > MAX_GLOBAL_LIMIT) {
            revert ErrorsLib.GlobalLimitOverFlow();
        }
        globalMintLimit = _newGlobalMintLimit;
        emit EventsLib.GlobalMintLimitSet(_newGlobalMintLimit);
    }

    /// @notice Sets `_newBurnDailyLimit` as `burnDailyLimit` of daily amount of principalToken burnable.
    /// @param _newBurnDailyLimit The daily limit of principalToken burnable.
    function _setBurnDailyLimit(uint256 _newBurnDailyLimit) private {
        burnDailyLimit = _newBurnDailyLimit;
        emit EventsLib.BurnableDailyLimitSet(_newBurnDailyLimit);
    }

    /// @notice Sets `_newBurnDailyLimit` as `globalBurnLimit` of max amount of principalToken burnable.
    /// @param _newGlobalBurnLimit The max limit of principalToken burnable.
    function _setGlobalBurnLimit(uint256 _newGlobalBurnLimit) private {
        if (_newGlobalBurnLimit > MAX_GLOBAL_LIMIT) {
            revert ErrorsLib.GlobalLimitOverFlow();
        }
        globalBurnLimit = MathLib.neg(_newGlobalBurnLimit);
        emit EventsLib.GlobalBurnLimitSet(_newGlobalBurnLimit);
    }

    /// @notice Sets `_newFeesRate` as `feesRate` of the fees applied on principalToken mint.
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
