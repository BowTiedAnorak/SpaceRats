pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IIridiumToken is IERC20{
    function mint(address _receiver, uint256 _amount) external;
}