// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface IIdentityPieceNFTEvents {
    event Initialize(
        address indexed owner,
        string name,
        string symbol,
        uint256 timestamp
    );
    event IdentityPieceNFTCreated(
        uint256 indexed identityPieceNFTId,
        address indexed creator,
        address indexed owner,
        uint256 timestamp
    );
    event IdentityPieceNFTUpdated(
        uint256 indexed identityPieceNFTId,
        address indexed creator,
        address indexed owner,
        uint256 timestamp
    );
    event DeployIdentityPieceNFT(
        uint256 issuerId,
        uint256 pieceId,
        address indexed identityPieceNFT,
        uint256 timestamp
    );
}
