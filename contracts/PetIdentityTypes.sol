// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

library PetIdentityTypes {
    struct Operator {
        string name;
        string country;
        string metadataUri;
    }

    struct GatherPieceData {
        address petAddress;
        uint256 petProfileId;
        uint256 issuerId;
        uint256 pieceId;
        address pieceBeacon;
    }

    struct GatherPieceParams {
        uint256 issuerId;
        uint256 pieceId;
        string name;
        string symbol;
        string pieceTokenURI;
        address pieceBeacon;
    }

    struct CreatePetProfile {
        string name;
        string chipId;
        string metadataUri;
    }

    struct ListingPieceParams {
        uint256 issuerId;
        string name;
        string symbol;
        string pieceTokenURI;
        bool shouldDeploy;
    }

    struct PetProfile {
        string name;
        string chipId;
        string metadataUri;
    }

    struct PieceStruct {
        address pieceNFT;
        string name;
        string symbol;
        string pieceTokenURI;
    }

    struct IssuerStruct {
        string name;
        address operator;
        uint256 numberOfPieces;
    }

    struct ListingPieceData {
        uint256 issuerId;
        uint256 pieceId;
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
