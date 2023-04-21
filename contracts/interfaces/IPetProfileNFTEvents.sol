// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface IPetProfileNFTEvents {
    /**
     * @notice Emitted when a contract is initialized
     * @param owner The address of the owner of the contract
     * @param backendService The address of the backend service
     * @param name The name of the contract
     * @param symbol The symbol of the contract
     */
    event Initialize(
        address indexed owner,
        address indexed backendService,
        string name,
        string symbol
    );

    /**
     * @notice Emitted when a new pet profile is minted
     * @param owner The address of the owner of the pet profile
     * @param petProfileId The ID of the pet profile
     * @param name The name of the pet
     * @param chipId The chip ID of the pet
     * @param metadataURI The metadata URI of the pet profile
     */
    event PetProfileCreated(
        address indexed owner,
        uint256 indexed petProfileId,
        string indexed chipId,
        string name,
        string metadataURI
    );
}
