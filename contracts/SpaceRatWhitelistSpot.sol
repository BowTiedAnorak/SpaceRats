pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "interfaces/IWhitelistMintERC721.sol";

contract SpaceRatWhitelistSpot is ERC1155, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private mintCount;

    uint256 public constant SPACE_RAT_WHITELIST = 1;
    uint256 public MAX_SUPPLY;

    address public GEODE_CONTRACT;
    IWhitelistMintERC721 public SPACE_RAT_CONTRACT;

    constructor(uint256 _maxSupply) ERC1155("") {
        MAX_SUPPLY = _maxSupply;
    }

    function setGeodeContract(address _geodeContract) public onlyOwner {
        GEODE_CONTRACT = _geodeContract;
    }

    function setSpaceRatContract(address _spaceRatContract) public onlyOwner {
        SPACE_RAT_CONTRACT = IWhitelistMintERC721(_spaceRatContract);
    }

    modifier onlyGeode() {
        require (msg.sender == GEODE_CONTRACT, "Only Geodes can call this function.");
        _;
    }

    // Mints a whitelist spot.
    function mint(address _receiver) public onlyGeode() {
        require (mintCount.current() < MAX_SUPPLY, "Maximum supply reached.");
        _mint(_receiver, SPACE_RAT_WHITELIST, 1, "");
        mintCount.increment();
    }

    function mintSpaceRat() public {
        require (balanceOf(msg.sender, SPACE_RAT_WHITELIST) >= 1, "No whitelist spots to mint a Space Rat.");
        SPACE_RAT_CONTRACT.whitelistMint(msg.sender);
        _burn(msg.sender, SPACE_RAT_WHITELIST, 1);
    }
}