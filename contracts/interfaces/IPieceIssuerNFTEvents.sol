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

    event OperatorSet(
        address indexed operator,
        address indexed sender,
        uint256 timestamp
    );

    event IssuerApplied(
        address indexed sender,
        address indexed operator,
        string name,
        uint256 timestamp
    );

    event PieceNFTListed(
        uint256 indexed issuerId,
        string name,
        string symbol,
        uint256 timestamp
    );

    event IssuerProfileCreated(
        address indexed sender,
        uint256 indexed issuerId,
        string metadataURI,
        uint256 timestamp
    );
}
