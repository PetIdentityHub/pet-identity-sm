// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {IIdentityPieceNFTEvents} from "./IIdentityPieceNFTEvents.sol";

interface IIdentityPieceNFT is IIdentityPieceNFTEvents {
    function initialize(
        address owner,
        string calldata name,
        string calldata symbol
    ) external;

    function mint(address to) external returns (uint256);
}
