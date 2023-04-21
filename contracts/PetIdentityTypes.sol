// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

library PetIdentityTypes {
    struct Operator {
        string name;
        string country;
        string metadataUri;
    }

    struct PetProfile {
        string name;
        string chipId;
        uint256[] pieces;
    }

    struct PetProfilePiece {
        string name;
        string description;
        string metadataURI;
    }

    struct PieceIssuer {
        string name;
        address operator;
    }

    struct ListingPieceData {
        uint256 pieceIssuerId;
        string name;
        string symbol;
        string pieceTokenURI;
    }

    struct ApplicationIssuerData {
        string name;
        address operator;
        string metadataURI;
    }
}
