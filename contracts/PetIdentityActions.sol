// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {PetIdentityNFTStorage} from "./PetIdentityNFTStorage.sol";
import {PetIdentityTypes} from "./PetIdentityTypes.sol";

library PetIdentityActions {
    function listingPiece(
        PetIdentityTypes.ListingPieceData calldata listingPieceData,
        mapping(uint256 => PetIdentityTypes.PieceIssuer)
            storage _pieceIssuerById,
        mapping(uint256 => mapping(uint256 => PetIdentityTypes.PieceIssuer))
            storage _pieceIssuerByPetProfileId
    ) external returns (uint256) {}

    function gatheringPiece() external returns (uint256) {}

    function addOperator(
        address operator,
        PetIdentityTypes.Operator calldata operatorData,
        mapping(address => PetIdentityTypes.Operator) storage _operators
    ) internal {
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
}
