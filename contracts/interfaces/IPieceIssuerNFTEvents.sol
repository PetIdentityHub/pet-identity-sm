// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface IPieceIssuerNFTEvents {
    event Initialize(
        address indexed owner,
        string name,
        string symbol,
        uint256 timestamp
    );
    event IssuerAccepted(
        address indexed issuer,
        address indexed operator,
        uint256 timestamp
    );

    event AddOperator(
        address indexed operator,
        address indexed sender,
        uint256 timestamp
    );
}
