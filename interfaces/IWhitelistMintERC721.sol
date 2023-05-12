pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IWhitelistMintERC721 is IERC20{
    function whitelistMint(address _receiver) external;
}