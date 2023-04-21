// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {PetIdentityTypes} from "./PetIdentityTypes.sol";

contract PetIdentityNFTStorage {
    /**
     * @dev Keeps track of pet profile data
     */
    mapping(uint256 => PetIdentityTypes.PetProfile) internal _petProfileById;
    /**
     * @dev Keeps track of pet profile id by chip
     */
    mapping(string => uint256) internal _petProfileIdByChipId;
    /**
     * @dev Keeps track of pet profile id by name hash
     */
    mapping(bytes32 => uint256) internal _petProfileIdByNameHash;
    /**
     * @dev Keeps track of pet profile piece data
     */
    mapping(uint256 => string) internal _chipIdByProfileId;
    /**
     * @dev Keeps track of accepted piece issuers
     */
    mapping(address => bool) internal _acceptedIssuers;
    /**
     * @dev Keeps track of piece issuer data
     */
    mapping(uint256 => PetIdentityTypes.PieceIssuer) internal _pieceIssuerById;
    /**
     * @dev Keeps track of aplicant wallet address and application data
     */
    mapping(address => PetIdentityTypes.ApplicationIssuerData)
        internal _applicationIssuerByWalletAddress;
    //TODO: this is not the best way to do it, but it works for now
    //I assume that operator will handle the application and will be able to
    //need add a way to get waiting applications by operator
    mapping(address => address[]) internal _applicationsByOperator;
    mapping(address => PetIdentityTypes.Operator) internal _operatorByAddress;
}
