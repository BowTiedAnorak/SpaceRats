pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract IridiumToken is ERC20 {

    address public owner;
    address public GEODE_CONTRACT;
    address public ASTEROID_CONTRACT;

    constructor () ERC20("Iridium", "IRI"){
        owner = msg.sender;
    }

    modifier onlyGeodeOrAsteroid {
        require (msg.sender == GEODE_CONTRACT || msg.sender == ASTEROID_CONTRACT, "Only the Geode and Asteroid Contracts can call this function.");
        _;
    }

    modifier onlyOwner {
        require (msg.sender == owner, "Only the owner can call this function.");
        _;
    }

    function revokeOwnership() public onlyOwner {
        owner = address(0);
    }

    function setGeodeContract(address _geodeContract) public onlyOwner {
        GEODE_CONTRACT = _geodeContract;
    }
    
    function setAsteroidContract(address _asteroidContract) public onlyOwner {
        ASTEROID_CONTRACT = _asteroidContract;
    }

    function mint(address _receiver, uint256 _amount) public onlyGeodeOrAsteroid {
        _mint(_receiver, _amount);
    }
}