// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.22;

struct Users {
    // Default owner for all contracts.
    address payable owner;
    // Default fee recipient for all contracts.
    address payable feeRecipient;
    // Impartial user.
    address payable alice;
    // Default second impartial user.
    address payable bob;
    // Default third impartial user.
    address payable carole;
    // Malicious user.
    address payable hacker;
}

