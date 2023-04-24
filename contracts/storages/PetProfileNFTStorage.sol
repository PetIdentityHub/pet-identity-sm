// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {PetIdentityTypes} from "../PetIdentityTypes.sol";

contract PetProfileNFTStorage {
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
}
