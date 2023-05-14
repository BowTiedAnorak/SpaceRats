pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "interfaces/IWhitelistMintERC721.sol";

contract SpaceshipKey is ERC1155, Ownable {

    uint256 public constant SPACESHIP_KEY = 1;

    address public GEODE_CONTRACT;

    constructor() ERC1155("") {
    }

    function setGeodeContract(address _geodeContract) public onlyOwner {
        GEODE_CONTRACT = _geodeContract;
    }

    modifier onlyGeode() {
        require (msg.sender == GEODE_CONTRACT, "Only Geodes can call this function.");
        _;
    }

    // Mints a SpaceshipKey.
    function mint(address _receiver) public onlyGeode() {
        _mint(_receiver, SPACESHIP_KEY, 1, "");
    }
}