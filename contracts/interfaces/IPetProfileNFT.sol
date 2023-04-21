// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {IPetProfileNFTEvents} from "./IPetProfileNFTEvents.sol";
import {PetIdentityTypes} from "../PetIdentityTypes.sol";

interface IPetProfileNFT is IPetProfileNFTEvents {
    /**
     * @notice onlyOwner - function to change the backend service address.
     * @dev contract has service address with role BACKEND_ROLE. It help us to keep standard of metadataUri.
     * @param _backendService address of the new service.
     */
    function changeService(address _backendService) external;

    /**
     * @notice onlyOwner - function to pause, triggers stopped state.
     */
    function pause() external;

    /**
     * @notice Only for contract owner - function to unpause, returns to normal state.
     */
    function unpause() external;

    /**
     * @notice For all users -function return profileId (nft tokenId) by chipId.
     * @param chipId chip id of the pet.
     */
    function getProfileIdByChipId(
        string memory chipId
    ) external view returns (uint256);

    /**
     * @notice For all users -function return chipId by profileId (nft tokenId).
     * @param profileId profile id (nft token id) of the pet.
     */
    function getChipId(uint256 profileId) external view returns (string memory);

    /**
     * @notice Only for pet owner - function update chipId of the pet profile.
     * @dev Could revert when validation fails.
     * @param profileId profile id (nft token id) of the pet.
     * @param chipId chip id of the pet.
     */
    function updateChipId(uint256 profileId, string memory chipId) external;

    /**
     * @notice For all users -function return profileId (nft tokenId) by name.
     * @param name name of the pet.
     */
    function getProfileIdByName(
        string memory name
    ) external view returns (uint256);

    /**
     * @notice For all users - function create pet profile and mint pet nft.
     * @dev Emit PetProfileCreated event. Could revert when validation fails.
     * @param petProfile PetProfile struct with pet data.
     * @param metadataURI metadata uri of the pet.
     */
    function createPetProfile(
        PetIdentityTypes.PetProfile calldata petProfile,
        string memory metadataURI
    ) external returns (uint256);

    /**
     * @notice Only by external service - function update metadataUri of the pet profile.
     * @dev Only for BACKEND_ROLE, casue we need to keep standard of metadataUri.
     */
    function updatePetProfileMetadata(
        uint256 profileId,
        address owner,
        string memory metadataURI
    ) external;
}
