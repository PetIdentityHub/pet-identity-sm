// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {ERC721Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";

import {IPetProfileNFT} from "./interfaces/IPetProfileNFT.sol";
import {PetIdentityBase} from "./PetIdentityBase.sol";
import {PetProfileNFTStorage} from "./storages/PetProfileNFTStorage.sol";
import {PetIdentityTypes} from "./PetIdentityTypes.sol";
import {PetIdentityActions} from "./PetIdentityActions.sol";

/**
 * @title PetProfileNFT
 * @author PetIdentityHub
 * @dev PetProfileNFT is a contract for managing pet profiles as NFTs
 */
contract PetProfileNFT is
    PausableUpgradeable,
    PetIdentityBase,
    PetProfileNFTStorage,
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
        __AccessControl_init();
        transferOwnership(owner);
        _service = service;
        _setupRole(BACKEND_ROLE, _service);
        _pause();

        emit Initialize(owner, service, name, symbol);
    }

    /**
     * @inheritdoc IPetProfileNFT
     */
    function pause(bool toPause) external onlyOwner {
        if (toPause) {
            _pause();
        } else {
            _unpause();
        }
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
    function getProfileIdByChipId(
        string memory chipId
    ) public view returns (uint256) {
        require(bytes(chipId).length > 0, "EMPTY_CHIP_ID");
        return _petProfileIdByChipId[chipId];
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
        PetIdentityTypes.CreatePetProfile calldata data
    ) public returns (uint256) {
        require(
            bytes(data.chipId).length > 0 &&
                bytes(data.metadataUri).length > 0 &&
                bytes(data.name).length > 0,
            "INVALID_INPUT"
        );
        require(
            _petProfileIdByChipId[data.chipId] == 0,
            "CHIP_ID_ALREADY_EXISTS"
        );

        uint256 newPetProfileId = _mint(msg.sender);
        bytes32 petNameHash = keccak256(abi.encodePacked(data.name));
        _setTokenURI(newPetProfileId, data.metadataUri);
        PetIdentityBase._setOwnedPetProfileId(msg.sender, newPetProfileId);
        PetIdentityActions.createProfilePostAction(
            data,
            newPetProfileId,
            petNameHash,
            _petProfileById,
            _petProfileIdByChipId,
            _petProfileIdByNameHash
        );

        emit PetProfileCreated(
            msg.sender,
            newPetProfileId,
            data.chipId,
            data.name,
            data.metadataUri
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
