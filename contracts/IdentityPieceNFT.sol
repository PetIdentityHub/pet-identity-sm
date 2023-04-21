// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "./PieceIssuerNFT.sol";

import {IIdentityPieceNFT} from "./interfaces/IIdentityPieceNFT.sol";
import {PetIdentityNFTStorage} from "./PetIdentityNFTStorage.sol";

contract IdentityPiecesNFT is
    PausableUpgradeable,
    PetIdentityBase,
    PetIdentityNFTStorage,
    OwnableUpgradeable,
    IIdentityPieceNFT
{
    function initialize(
        address owner,
        string calldata name,
        string calldata symbol
    ) public initializer {
        require(owner != address(0), "INVALID_OWNER");
        require(bytes(name).length > 0, "EMPTY_NAME");
        require(bytes(symbol).length > 0, "EMPTY_SYMBOL");
        __ERC721_init(name, symbol);
        __Ownable_init();
        transferOwnership(owner);

        emit Initialize(owner, name, symbol, block.timestamp);
    }

    function mintPiece(
        address to,
        uint256 tokenId,
        string memory tokenURI
    ) external {
        _mint(to, tokenId);
        _setTokenURI(tokenId, tokenURI);
    }

    // ************** PUBLIC **************
    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }
}
