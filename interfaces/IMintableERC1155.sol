pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

interface IMintableERC1155 is IERC1155 {
    function mint(address _receiver) external;
}