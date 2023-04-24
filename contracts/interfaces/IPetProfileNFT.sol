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

    function pause(bool toPause) external;

    /**
     * @notice For all users -function return profileId (nft tokenId) by chipId.
     * @param chipId chip id of the pet.
     */
    function getProfileIdByChipId(
        string memory chipId
    ) external view returns (uint256);

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
     * @param data PetProfile struct with pet data.
     */
    function createPetProfile(
        PetIdentityTypes.CreatePetProfile calldata data
    ) external returns (uint256);

    function updatePetProfileMetadata(
        uint256 profileId,
        address owner,
        string memory metadataURI
    ) external;
}
