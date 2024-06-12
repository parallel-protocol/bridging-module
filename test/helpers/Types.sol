// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

struct Users {
    // Default owner for all contracts.
    address payable owner;
    // Default fees recipient for all contracts.
    address payable feesRecipient;
    // Impartial user.
    address payable alice;
    // Impartial user.
    address payable bob;
    // Malicious user.
    address payable hacker;
}
