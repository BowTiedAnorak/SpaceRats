pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "interfaces/IIridiumToken.sol";
import "interfaces/IWhitelistSpot.sol";
import "interfaces/ISpaceshipKey.sol";

contract Geode is ERC1155, Ownable {
    using Counters for Counters.Counter;

    address public ASTEROID_MINE;
    IWhitelistSpot public WHITELIST_SPOT;
    ISpaceshipKey public SPACESHIP_KEY;
    IIridiumToken public IRIDIUM_TOKEN;

    Counters.Counter private _whitelistSpotsMinted;
    uint256 public WHITELIST_MAX = 1_000;
    uint256 public constant GEODE = 1;

    constructor() ERC1155("") {}

    function setAsteroidMineContract(address _asteroidMine) public onlyOwner {
        ASTEROID_MINE = _asteroidMine;
    }

    function setWhitelistSpot(address _whitelistSpot) public onlyOwner {
        WHITELIST_SPOT = IWhitelistSpot(_whitelistSpot);
    }

    function setSpaceshipKey(address _spaceshipKey) public onlyOwner {
        SPACESHIP_KEY = ISpaceshipKey(_spaceshipKey);
    }
    
    function setIridiumTokenContract(address _iridiumToken) public onlyOwner {
        IRIDIUM_TOKEN = IIridiumToken(_iridiumToken);
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
        //      Limit minting of WhitelistSpots to 1,000.
        uint256 randomNumber = randomNumberBelow(100);
        // 1% chance of minting a WhitelistSpot. Mints a SpaceshipKey if Whitelists are taken.
        if (randomNumber == 98){
            if (_whitelistSpotsMinted.current() >= WHITELIST_MAX){
                _whitelistSpotsMinted.increment();
                WHITELIST_SPOT.mint(msg.sender);
            } else {
                SPACESHIP_KEY.mint(msg.sender);
            }
        } else if (randomNumber == 99){
                SPACESHIP_KEY.mint(msg.sender);
        } else {
            // 10% chance of minting 300_000 tokens.
            if (randomNumber < 10) {
                IRIDIUM_TOKEN.mint(msg.sender, 300_000);
            } else {
                IRIDIUM_TOKEN.mint(msg.sender, 50_000);
            }
        }

        // Burn the Geode
        _burn(msg.sender, GEODE, 1);
    }

    // Not actually random - predictable randomness using the Blockhash.
    function randomNumberBelow(uint256 max) internal view returns (uint256) {
        return uint256(blockhash(block.number - 1)) % max;
    }
}