// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {BeaconProxy} from "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";

import {PetProfileNFTStorage} from "./storages/PetProfileNFTStorage.sol";
import {PieceIssuerNFTStorage} from "./storages/PieceIssuerNFTStorage.sol";
import {PetIdentityTypes} from "./PetIdentityTypes.sol";

import {IIdentityPieceNFT} from "./interfaces/IIdentityPieceNFT.sol";

library PetIdentityActions {
    function setOperator(
        address operator,
        PetIdentityTypes.Operator calldata operatorData,
        mapping(address => PetIdentityTypes.Operator) storage _operators
    ) external {
        require(operator != address(0), "INVALID_ADDR");
        require(bytes(operatorData.name).length > 0, "EMPTY_NAME");
        require(bytes(operatorData.country).length > 0, "EMPTY_COUNTRY");
        require(
            bytes(operatorData.metadataUri).length > 0,
            "EMPTY_METADATA_URI"
        );
        _operators[operator] = operatorData;
    }

    function applyAsIssuer(
        address sender,
        PetIdentityTypes.ApplicationIssuerData calldata data,
        mapping(address => PetIdentityTypes.ApplicationIssuerData)
            storage _applicationIssuerByWalletAddress,
        mapping(address => address[]) storage _applicationsByOperator,
        mapping(address => PetIdentityTypes.Operator) storage _operatorByAddress
    ) external {
        require(data.operator != address(0), "INVALID_ADDRESS");
        require(bytes(data.name).length > 0, "EMPTY_NAME");
        require(bytes(data.metadataURI).length > 0, "EMPTY_METADATA_URI");
        require(
            bytes(_operatorByAddress[data.operator].name).length > 0,
            "INVALID_OPERATOR"
        );
        _applicationIssuerByWalletAddress[sender] = data;
        _applicationsByOperator[data.operator].push(sender);
    }

    function acceptIssuer(
        address issuer,
        address operator,
        mapping(address => PetIdentityTypes.ApplicationIssuerData)
            storage _applicationIssuerByWalletAddress,
        mapping(address => PetIdentityTypes.Operator)
            storage _operatorByAddress,
        mapping(address => bool) storage _acceptedIssuers
    ) external {
        require(issuer != address(0), "INVALID_ADDRESS");
        require(operator != address(0), "INVALID_ADDRESS");
        require(
            bytes(_operatorByAddress[operator].name).length > 0,
            "INVALID_OPERATOR"
        );
        require(
            bytes(_applicationIssuerByWalletAddress[issuer].name).length > 0,
            "INVALID_APPLICATION"
        );
        _acceptedIssuers[issuer] = true;
    }

    function gatherPiece(
        PetIdentityTypes.GatherPieceParams calldata params,
        mapping(uint256 => mapping(uint256 => PetIdentityTypes.PieceStruct))
            storage _pieceByIdByIssuerId
    ) external returns (uint256 tokenId) {
        address pieceNFT = _pieceByIdByIssuerId[params.issuerId][params.pieceId]
            .pieceNFT;
        if (pieceNFT == address(0)) {
            pieceNFT = _deployPieceNFT(
                params.issuerId,
                params.pieceId,
                params.name,
                params.symbol,
                params.pieceBeacon,
                _pieceByIdByIssuerId
            );
        }

        tokenId = IIdentityPieceNFT(pieceNFT).mint(msg.sender);
    }

    function listingPieceNFT(
        PetIdentityTypes.ListingPieceParams calldata params,
        address identityPieceBeacon,
        mapping(uint256 => PetIdentityTypes.IssuerStruct)
            storage _pieceIssuerById,
        mapping(uint256 => mapping(uint256 => PetIdentityTypes.PieceStruct))
            storage _pieceByIdByIssuerId
    ) external {
        require(
            bytes(_pieceIssuerById[params.issuerId].name).length > 0,
            "INVALID_ISSUER"
        );
        require(bytes(params.name).length > 0, "EMPTY_NAME");
        require(bytes(params.symbol).length > 0, "EMPTY_SYMBOL");
        require(bytes(params.pieceTokenURI).length > 0, "EMPTY_METADATA_URI");

        uint256 pieceId = ++_pieceIssuerById[params.issuerId].numberOfPieces;
        _pieceByIdByIssuerId[params.issuerId][pieceId].name = params.name;
        _pieceByIdByIssuerId[params.issuerId][pieceId].symbol = params.symbol;
        _pieceByIdByIssuerId[params.issuerId][pieceId].pieceTokenURI = params
            .pieceTokenURI;

        if (params.shouldDeploy) {
            _deployPieceNFT(
                params.issuerId,
                pieceId,
                params.name,
                params.symbol,
                identityPieceBeacon,
                _pieceByIdByIssuerId
            );
        }
    }

    function _deployPieceNFT(
        uint256 issuerId,
        uint256 pieceId,
        string calldata name,
        string calldata symbol,
        address identityPieceBeacon,
        mapping(uint256 => mapping(uint256 => PetIdentityTypes.PieceStruct))
            storage _pieceByIdByIssuerId
    ) private returns (address) {
        bytes memory initData = abi.encodeWithSelector(
            IIdentityPieceNFT.initialize.selector,
            issuerId,
            name,
            symbol
        );

        address pieceNFT = address(
            new BeaconProxy{
                salt: keccak256(abi.encodePacked(issuerId, pieceId))
            }(identityPieceBeacon, initData)
        );

        _pieceByIdByIssuerId[issuerId][pieceId].pieceNFT = pieceNFT;
        //Event issuerId, pieceId, pieceNFT

        return pieceNFT;
    }

    function createProfilePostAction(
        PetIdentityTypes.CreatePetProfile calldata data,
        uint256 petProfileId,
        bytes32 petNameHash,
        mapping(uint256 => PetIdentityTypes.PetProfile) storage _petProfileById,
        mapping(string => uint256) storage _petProfileIdByChipId,
        mapping(bytes32 => uint256) storage _petProfileIdByNameHash
    ) external {
        _petProfileIdByChipId[data.chipId] = petProfileId;
        _petProfileById[petProfileId].name = data.name;
        _petProfileById[petProfileId].chipId = data.chipId;
        _petProfileById[petProfileId].metadataUri = data.metadataUri;
        _petProfileIdByNameHash[petNameHash] = petProfileId;
    }
}
