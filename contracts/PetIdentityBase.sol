// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import {IPetIdentityBase} from "./interfaces/IPetIdentityBase.sol";

/**
 * @title PetIdentity NFT Base
 * @author PetIdentityHub
 * @dev PetIdentity NFT Base is a contract for managing pet profiles as NFTs
 */
abstract contract PetIdentityBase is
    ERC721URIStorageUpgradeable,
    IPetIdentityBase
{
    /*** STATE VARIABLES ***/
    uint256 internal _currentIndex;
    uint256 internal _burnCount;
    mapping(address => uint256) public nonces;

    /*** PUBLIC */
    /**
     * @inheritdoc IPetIdentityBase
     */
    function burn(uint256 tokenId) public virtual {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );
        super._burn(tokenId);
        _burnCount++;
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
