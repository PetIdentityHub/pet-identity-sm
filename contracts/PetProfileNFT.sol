// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";

import {IPetProfileNFT} from "./interfaces/IPetProfileNFT.sol";
import {PetIdentityBase} from "./PetIdentityBase.sol";
import {PetIdentityNFTStorage} from "./PetIdentityNFTStorage.sol";
import {PetIdentityTypes} from "./PetIdentityTypes.sol";

/**
 * @title PetProfileNFT
 * @author PetIdentityHub
 * @dev PetProfileNFT is a contract for managing pet profiles as NFTs
 */
contract PetProfileNFT is
    PausableUpgradeable,
    PetIdentityBase,
    PetIdentityNFTStorage,
    OwnableUpgradeable,
    AccessControlUpgradeable,
    IPetProfileNFT
{
    modifier isApprovedOrOwner(uint256 profileId, address owner) {
        require(
            _isApprovedOrOwner(owner, profileId),
            "ERC721: caller is not owner nor approved"
        );
        _;
    }

    bytes32 public constant BACKEND_ROLE = keccak256("BACKEND_ROLE");
    address private _service;

    function initialize(
        address owner,
        address service,
        string calldata name,
        string calldata symbol
    ) external initializer {
        require(
            owner != address(0) && service != address(0),
            "INVALID_ADDRESS"
        );
        require(bytes(name).length > 0, "EMPTY_NAME");
        require(bytes(symbol).length > 0, "EMPTY_SYMBOL");
        __PetProfileNFT_init(owner, service, name, symbol);
    }

    function __PetProfileNFT_init(
        address owner,
        address service,
        string calldata name,
        string calldata symbol
    ) internal initializer {
        __ERC721_init(name, symbol);
        __Ownable_init();
        __Pausable_init();
        __AccessControl_init();
        transferOwnership(owner);
        _service = service;
        _setupRole(BACKEND_ROLE, _service);

        emit Initialize(owner, service, name, symbol);
    }

    /**
     * @inheritdoc IPetProfileNFT
     */
    function changeService(address backendService) external onlyOwner {
        require(_service != address(0), "INVALID_ADDRESS");
        revokeRole(BACKEND_ROLE, _service);
        _setupRole(BACKEND_ROLE, backendService);
        _service = backendService;
    }

    /**
     * @inheritdoc IPetProfileNFT
     */
    function pause() public onlyOwner {
        _pause();
    }

    /**
     * @inheritdoc IPetProfileNFT
     */
    function unpause() public onlyOwner {
        _unpause();
    }

    /**
     * @inheritdoc IPetProfileNFT
     */
    function getProfileIdByChipId(
        string memory chipId
    ) public view returns (uint256) {
        require(bytes(chipId).length > 0, "EMPTY_CHIP_ID");
        return _petProfileIdByChipId[chipId];
    }

    /**
     * @inheritdoc IPetProfileNFT
     */
    function getChipId(uint256 profileId) public view returns (string memory) {
        require(_exists(profileId), "ERC721: invalid token ID");
        return _chipIdByProfileId[profileId];
    }

    /**
     * @inheritdoc IPetProfileNFT
     */
    function updateChipId(
        uint256 profileId,
        string memory chipId
    ) external isApprovedOrOwner(profileId, _msgSender()) {
        require(_exists(profileId), "ERC721: invalid token ID");
        require(bytes(chipId).length > 0, "EMPTY_CHIP_ID");
        _chipIdByProfileId[profileId] = chipId;
    }

    /**
     * @inheritdoc IPetProfileNFT
     */
    function getProfileIdByName(
        string memory name
    ) external view returns (uint256) {
        require(bytes(name).length > 0, "EMPTY_PET_NAME");
        bytes32 nameHash = keccak256(abi.encodePacked(name));
        return _petProfileIdByNameHash[nameHash];
    }

    /**
     * @inheritdoc IPetProfileNFT
     */
    function createPetProfile(
        PetIdentityTypes.PetProfile calldata petProfile,
        string memory metadataURI
    ) public returns (uint256) {
        require(
            bytes(petProfile.chipId).length > 0 &&
                bytes(metadataURI).length > 0 &&
                bytes(petProfile.name).length > 0,
            "INVALID_INPUT"
        );
        require(
            _petProfileIdByChipId[petProfile.chipId] == 0,
            "CHIP_ID_ALREADY_EXISTS"
        );

        uint256 newPetProfileId = _mint(msg.sender);
        bytes32 petNameHash = keccak256(abi.encodePacked(petProfile.name));
        _setTokenURI(newPetProfileId, metadataURI);
        _chipIdByProfileId[newPetProfileId] = petProfile.chipId;
        _petProfileIdByChipId[petProfile.chipId] = newPetProfileId;
        _petProfileById[newPetProfileId] = petProfile;
        _petProfileIdByNameHash[petNameHash] = newPetProfileId;

        emit PetProfileCreated(
            msg.sender,
            newPetProfileId,
            petProfile.chipId,
            petProfile.name,
            metadataURI
        );

        return newPetProfileId;
    }

    /**
     * @inheritdoc IPetProfileNFT
     */
    function updatePetProfileMetadata(
        uint256 profileId,
        address owner,
        string memory metadataURI
    )
        public
        onlyRole(BACKEND_ROLE)
        whenNotPaused
        isApprovedOrOwner(profileId, owner)
    {
        _setTokenURI(profileId, metadataURI);
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(ERC721Upgradeable, AccessControlUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
