pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "interfaces/IMintableERC20.sol";

contract Geode is ERC1155, Ownable {

    address public ASTEROID_MINE;
    IMintableERC20 public IRIDIUM_TOKEN;

    uint256 public constant GEODE = 1;

    constructor() ERC1155("") {}

    function setAsteroidMineContract(address _asteroidMine) public onlyOwner {
        ASTEROID_MINE = _asteroidMine;
    }
    
    function setIridiumTokenContract(address _iridiumToken) public onlyOwner {
        IRIDIUM_TOKEN = IMintableERC20(_iridiumToken);
    }

    modifier onlyAsteroidMine() {
        require (msg.sender == ASTEROID_MINE, "Only the Asteroid Mine Contract can call this function.");
        _;
    }

    function mint(address _receiver) public onlyAsteroidMine {
        _mint(_receiver, GEODE, 1, "");
    }

    function crackOpen() public {
        require (balanceOf(msg.sender, GEODE) > 0, "Caller must have a Geode to open.");
        // TODO: Randomly select a prize (Token, WhitelistSpot or SpaceshipKey)
        IRIDIUM_TOKEN.mint(msg.sender, 100);

        // Burn the Geode
        _burn(msg.sender, GEODE, 1);
    }
}