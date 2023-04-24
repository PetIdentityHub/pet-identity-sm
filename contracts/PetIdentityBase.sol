// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import {IPetIdentityBase} from "./interfaces/IPetIdentityBase.sol";

/**
 * @title PetIdentity NFT Base
 * @author PetIdentityHub
 * @dev PetIdentity NFT Base is a contract for managing pet profiles as NFTs
 */
abstract contract PetIdentityBase is
    Initializable,
    ERC721Upgradeable,
    IPetIdentityBase
{
    /*** STATE VARIABLES ***/
    uint256 internal _currentIndex;
    uint256 internal _burnCount;
    mapping(uint256 => string) private _tokenURIs;
    mapping(address => uint256[]) private _ownerTokens;

    /**
     * @inheritdoc IPetIdentityBase
     */
    function burn(uint256 tokenId) public virtual {
        super._burn(tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
        _burnCount++;
    }

    function getOwnedPetProfiles(
        address owner
    ) public view virtual returns (uint256[] memory) {
        return _ownerTokens[owner];
    }

    function _setOwnedPetProfileId(
        address owner,
        uint256 tokenId
    ) internal virtual {
        _ownerTokens[owner].push(tokenId);
    }

    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        _requireMinted(tokenId);

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }

        return super.tokenURI(tokenId);
    }

    function _setTokenURI(
        uint256 tokenId,
        string memory _tokenURI
    ) internal virtual {
        require(_exists(tokenId), "TOKEN_DOES_NOT_EXIST");
        _tokenURIs[tokenId] = _tokenURI;
    }

    function transferFrom(address, address, uint256) public pure override {
        revert("NOT_ALLOWED");
    }

    function safeTransferFrom(address, address, uint256) public pure override {
        revert("NOT_ALLOWED");
    }

    function safeTransferFrom(
        address,
        address,
        uint256,
        bytes memory
    ) public pure override {
        revert("NOT_ALLOWED");
    }

    function approve(address, uint256) public pure override {
        revert("NOT_ALLOWED");
    }

    function setApprovalForAll(address, bool) public pure override {
        revert("NOT_ALLOWED");
    }

    /*** EXTERNAL ***/
    /**
     * @inheritdoc IPetIdentityBase
     */
    function totalSupply() external view virtual returns (uint256) {
        return _currentIndex - _burnCount;
    }

    /**
     * @inheritdoc IPetIdentityBase
     */
    function totalMinted() external view virtual returns (uint256) {
        return _currentIndex;
    }

    /**
     * @inheritdoc IPetIdentityBase
     */
    function totalBurned() external view virtual returns (uint256) {
        return _burnCount;
    }

    /*** INTERNAL ***/
    function _initialize(
        string memory _name,
        string memory _symbol
    ) internal initializer {
        __ERC721_init(_name, _symbol);
    }

    function _mint(address _to) internal virtual returns (uint256) {
        super._safeMint(_to, ++_currentIndex);
        return _currentIndex;
    }

    function _exists(
        uint256 tokenId
    ) internal view virtual override returns (bool) {
        return super._exists(tokenId);
    }
}
