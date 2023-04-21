// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

interface IPetIdentityBase {
    /**
     * @dev Returns the total number of tokens in existence.
     * @return uint256 representing the total number of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the total number of tokens minted.
     * @return uint256 representing the total number of tokens minted.
     */
    function totalMinted() external view returns (uint256);

    /**
     * @dev Returns the total number of tokens burned.
     * @return uint256 representing the total number of tokens burned.
     */
    function totalBurned() external view returns (uint256);

    /**
     * @dev Burns a token.
     * @param tokenId uint256 ID of the token to be burned.
     */
    function burn(uint256 tokenId) external;
}
