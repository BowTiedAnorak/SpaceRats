pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SpaceRat is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    Counters.Counter private _publicCount;
    Counters.Counter private _whitelistCount;

    uint256 public PUBLIC_SUPPLY = 1_000;
    uint256 public WHITELIST_SUPPLY = 1_000;
    
    address public WHITELIST_CONTRACT = address(0);

    constructor(uint256 _publicSupply, uint256 _whitelistSupply) ERC721("SpaceRat", "SR"){
        PUBLIC_SUPPLY = _publicSupply;
        WHITELIST_SUPPLY = _whitelistSupply;
    }

    function setWhitelistContract(address _whitelistContract) public onlyOwner {
        // Only allow the whitelist contract address to be set once.
        require (WHITELIST_CONTRACT == address(0), "Whitelist Contract Address has already been set.");
        WHITELIST_CONTRACT = _whitelistContract;
    }

    function publicMint(address receiver)
        public
        returns (uint256)    
    {
        require(_publicCount.current() < PUBLIC_SUPPLY, "Maximum Public mint reached.");
        _tokenIds.increment();
        _publicCount.increment();
        
        uint256 newItemId = _tokenIds.current();
        _mint(receiver, newItemId);
        return newItemId;
    }

    function whitelistMint(address receiver)
        public
        returns (uint256)    
    {
        require(_whitelistCount.current() < WHITELIST_SUPPLY, "Maximum Whitelist mint reached.");
        require(msg.sender == WHITELIST_CONTRACT, "Only the Whitelist Contract can call this function.");

        _tokenIds.increment();
        _whitelistCount.increment();
        
        uint256 newItemId = _tokenIds.current();
        _mint(receiver, newItemId);
        return newItemId;
    }
}