// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {IPieceIssuerNFTEvents} from "./IPieceIssuerNFTEvents.sol";
import {PetIdentityTypes} from "../PetIdentityTypes.sol";

interface IPieceIssuerNFT is IPieceIssuerNFTEvents {
    function initialize(
        address pieceBeacon,
        address owner,
        string calldata name,
        string calldata symbol
    ) external;

    /**
     * @notice onlyOwner - function to start or stop contract functionality.
     * @param toPause bool value to set pause state. true - when pause, false - when not.
     */
    function pause(bool toPause) external;

    /**
     * @notice everyone - function create issuer profile and mint nft.
     * @dev Emit IssuerProfileCreated event. Could revert when validation fails.
     * @param sender address of the sender.
     * @param metadataURI metadata uri of the issuer.
     */
    function createIssuerProfile(
        address sender,
        string memory metadataURI
    ) external returns (uint256);

    /**
     * @notice everyone - function to apply as piece issuer
     * @dev Emit IssuerApplied event. Could revert when validation fails.
     * @param sender address of the sender.
     * @param data ApplicationIssuerData struct with application data.
     */
    function applyAsIssuer(
        address sender,
        PetIdentityTypes.ApplicationIssuerData calldata data
    ) external;

    /**
     * @notice everyone - get application as piece issuer data by applicant address.
     * @dev could revert when application not exist.
     * @param applicant address of the applicant.
     */
    function getApplication(
        address applicant
    ) external view returns (PetIdentityTypes.ApplicationIssuerData memory);

    /**
     * @notice onlyOwner - function to accept new piece issuer.
     */
    function acceptIssuer(address issuer, address operator) external;

    /**
     * @notice everyone - function used to list piece nft belong to issuer.
     * @dev Emit PieceNFTListed event. Logic wrapped into library. Could revert when validation fails.
     */
    function listPiece(
        PetIdentityTypes.ListingPieceParams calldata data
    ) external;

    /**
     * @notice onlyOwner - function used to add new operator. Operator can accept application of piece issuer.
     */
    function setOperator(
        address operator,
        PetIdentityTypes.Operator calldata operatorData
    ) external;

    function getOperator(
        address operator
    ) external view returns (PetIdentityTypes.Operator memory);
}
