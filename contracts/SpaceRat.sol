pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract SpaceRat is ERC721 {

    uint256 MAX_SUPPLY = 2000;
    uint256 PUBLIC_SUPPLY = 1000;
    uint256 WHITELIST_SUPPLY = 1000;

    constructor() ERC721("SpaceRat", "SR"){}

}