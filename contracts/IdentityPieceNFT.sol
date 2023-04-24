// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "./PieceIssuerNFT.sol";

import {IIdentityPieceNFT} from "./interfaces/IIdentityPieceNFT.sol";

contract IdentityPiecesNFT is
    PausableUpgradeable,
    PetIdentityBase,
    OwnableUpgradeable,
    IIdentityPieceNFT
{
    function initialize(
        address owner,
        string calldata name,
        string calldata symbol
    ) external initializer {
        require(owner != address(0), "INVALID_OWNER");
        require(bytes(name).length > 0, "EMPTY_NAME");
        require(bytes(symbol).length > 0, "EMPTY_SYMBOL");
        __ERC721_init(name, symbol);
        __Ownable_init();
        transferOwnership(owner);

        emit Initialize(owner, name, symbol, block.timestamp);
    }

    function mint(address to) external returns (uint256) {
        return _mint(to);
    }

    // ************** PUBLIC **************
    function pause(bool toPause) external onlyOwner {
        if (toPause) {
            _pause();
        } else {
            _unpause();
        }
    }
}
