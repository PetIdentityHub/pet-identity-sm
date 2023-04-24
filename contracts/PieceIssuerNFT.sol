// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";

import {IPieceIssuerNFT} from "./interfaces/IPieceIssuerNFT.sol";
import {PetIdentityBase} from "./PetIdentityBase.sol";
import {PieceIssuerNFTStorage} from "./storages/PieceIssuerNFTStorage.sol";
import {PetIdentityTypes} from "./PetIdentityTypes.sol";
import {PetIdentityActions} from "./PetIdentityActions.sol";

contract PieceIssuerNFT is
    PausableUpgradeable,
    PetIdentityBase,
    PieceIssuerNFTStorage,
    OwnableUpgradeable,
    IPieceIssuerNFT
{
    address public PIECE_BEACON;

    function initialize(
        address pieceBeacon,
        address owner,
        string calldata name,
        string calldata symbol
    ) public initializer {
        require(owner != address(0), "INVALID_OWNER");
        require(pieceBeacon != address(0), "INVALID_BEACON");
        require(bytes(name).length > 0, "EMPTY_NAME");
        require(bytes(symbol).length > 0, "EMPTY_SYMBOL");
        PIECE_BEACON = pieceBeacon;
        PetIdentityBase._initialize(name, symbol);
        __Ownable_init();
        transferOwnership(owner);
        _pause();
        emit Initialize(owner, name, symbol, block.timestamp);
    }

    // ************** PUBLIC **************
    function pause(bool toPause) external onlyOwner {
        if (toPause) {
            _pause();
        } else {
            _unpause();
        }
    }

    function createIssuerProfile(
        address sender,
        string memory metadataURI
    ) public returns (uint256) {
        require(sender != address(0), "INVALID_ADDRESS");
        require(bytes(metadataURI).length > 0, "EMPTY_METADATA_URI");
        require(_acceptedIssuers[sender] == true, "NOT_ACCEPTED_ISSUER");

        uint256 newIssuerId = _mint(sender);
        _setTokenURI(newIssuerId, metadataURI);

        return newIssuerId;
    }

    // ************** EXTERNAL **************
    function applyAsIssuer(
        address sender,
        PetIdentityTypes.ApplicationIssuerData calldata data
    ) external whenNotPaused {
        PetIdentityActions.applyAsIssuer(
            sender,
            data,
            _applicationIssuerByWalletAddress,
            _applicationsByOperator,
            _operatorByAddress
        );
    }

    function getApplication(
        address applicant
    ) external view returns (PetIdentityTypes.ApplicationIssuerData memory) {
        require(applicant != address(0), "INVALID_ADDRESS");
        return _applicationIssuerByWalletAddress[applicant];
    }

    function acceptIssuer(
        address issuer,
        address operator
    ) external onlyOwner whenNotPaused {
        PetIdentityActions.acceptIssuer(
            issuer,
            operator,
            _applicationIssuerByWalletAddress,
            _operatorByAddress,
            _acceptedIssuers
        );
        emit IssuerAccepted(issuer, operator, block.timestamp);
    }

    function registerPiece(
        PetIdentityTypes.ListingPieceParams calldata data
    ) external whenNotPaused {
        PetIdentityActions.listingPieceNFT(
            data,
            PIECE_BEACON,
            _pieceIssuerById,
            _pieceByIdByIssuerId
        );
    }

    function addOperator(
        address operator,
        PetIdentityTypes.Operator calldata operatorData
    ) external onlyOwner whenNotPaused {
        PetIdentityActions.setOperator(
            operator,
            operatorData,
            _operatorByAddress
        );
        emit AddOperator(operator, msg.sender, block.timestamp);
    }

    function getOperator(
        address operator
    ) external view returns (PetIdentityTypes.Operator memory) {
        require(operator != address(0), "INVALID_ADDRESS");
        return _operatorByAddress[operator];
    }
}
