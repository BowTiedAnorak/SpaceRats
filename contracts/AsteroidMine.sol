pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "interfaces/IMintableERC20.sol";

/**
 * Staking contract for SpaceRat NFTs.
 * Mints Geodes & Iridium Tokens to stakers.
 * Functions are SpaceRat specific so in the future staking of Spaceships will be possible.
 * Staking spaceships will change the rate of rewards.
 * Based on: https://github.com/andreitoma8/Synthetix-ERC721-Staking/blob/master/contracts/ERC721Staking.sol
 */
contract AsteroidMine is ReentrancyGuard {

    // Variables to store the contract addresses of the NFTs & Tokens the
    // Asteroid Mine will interact with.
    IMintableERC20 public IRIDIUM_TOKEN;
    IERC1155 public GEODE_NFT;
    IERC721 public SPACE_RAT_NFT;

    // Variables to keep track of state of the contract.
    uint256 public totalRatsStaked;
    // 1 Reward Per Second per Rat Staked
    uint256 rewardRate = 1;
    // uint256 spaceshipBoostRate = 1;
    
    // Variables to keep track of assets staked.
    // Mappings from Address to Token & vice versa.
    mapping(uint256 => address) public stakedAssets;
    mapping(address => uint256[]) public ratsStaked;
    // Required to find an NFT ID when a staker has multiple NFTs staked.
    // (ratsStaked is an array).
    mapping(uint256 => uint256) public spaceRatIdToIndex;
    
    // Stores the rewards a user has accrued.
    mapping(address => uint256) public userRewards;
    // Stores the date of the last time the user's rewards were updated.
    mapping(address => uint256) public userRewardsLastUpdate;

    constructor(address _iridiumToken, address _geodeNft, address _spaceRatNft) {
        IRIDIUM_TOKEN = IMintableERC20(_iridiumToken);
        GEODE_NFT = IERC1155(_spaceRatNft);
        SPACE_RAT_NFT = IERC721(_spaceRatNft);
    }

    // A function to stake Space Rats.
    // A separate function will be built in future to stake Spaceships.
    function stakeSpaceRats(uint256[] memory spaceRatIds) external updateReward(msg.sender) {
        require(spaceRatIds.length != 0, "No Space Rat IDs provided.");
        uint256 amount = spaceRatIds.length;
        for (uint256 i = 0; i < amount; i += 1) {
            SPACE_RAT_NFT.safeTransferFrom(msg.sender, address(this), spaceRatIds[i]);

            stakedAssets[spaceRatIds[i]] = msg.sender;
            ratsStaked[msg.sender].push(spaceRatIds[i]);
            spaceRatIdToIndex[spaceRatIds[i]] = ratsStaked[msg.sender].length - 1;
        }
        totalRatsStaked += amount;
        emit RatsStaked(msg.sender, spaceRatIds);
    }

    function withdrawSpaceRats(uint256[] memory spaceRatIds) public nonReentrant updateReward(msg.sender) {
        require(spaceRatIds.length != 0, "No Space Rat IDs provided.");
        uint256 amount = spaceRatIds.length;
        for (uint256 i = 0; i < amount; i += 1){
            require(stakedAssets[spaceRatIds[i]] == msg.sender, "Only the staker can withdraw.");
            SPACE_RAT_NFT.safeTransferFrom(address(this), msg.sender, spaceRatIds[i]);
            stakedAssets[spaceRatIds[i]] = address(0);

            // List of Rat IDs staked before withdrawal.
            uint256[] storage userTokens = ratsStaked[msg.sender];
            // Index of the Rat being withdrawn.
            uint256 index = spaceRatIdToIndex[spaceRatIds[i]];
            // Index of the last token in the list of staked rats.
            uint256 lastTokenIdIndex = userTokens.length - 1;
            // We are going to remove the last element of the user's staked rats.
            // If the Rat being withdrawn is the last element then we can proceed.
            // If the Rat is not the last element then we replace it with the token that is the last element.
            // And then remove the last token.
            if (index != lastTokenIdIndex) {
                uint256 lastTokenId = userTokens[lastTokenIdIndex];
                userTokens[index] = lastTokenId;
                spaceRatIdToIndex[lastTokenId] = index;
            }
            userTokens.pop();
        }
        totalRatsStaked -= amount;
        emit RatsWithdrawn(msg.sender, spaceRatIds);
    }

    // TODO: Needs to determine whether to mint Iridium Tokens or Geodes.
    function claimRewards() public nonReentrant updateReward(msg.sender) {
        uint256 reward = userRewards[msg.sender];
        if (reward > 0) {
            userRewards[msg.sender] = 0;
            IRIDIUM_TOKEN.mint(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
        }
    }

    function withdrawAll() external {
        withdrawSpaceRats(ratsStaked[msg.sender]);
        claimRewards();
    }

    // TODO: Add the logic to calculate Rewards.
    // Udpate Rewards based on:
    //      Number of Rats Staked * Number of seconds since last update.
    // Update lastUpdated value to 'now'.
    modifier updateReward(address user) {
        uint256 userRatsStaked = ratsStaked[user].length;
        uint256 currentReward = userRewards[user];
        uint256 lastReward = userRewardsLastUpdate[user];
        _;
    }

    event RatsStaked(address indexed user, uint256[] spaceRatIds);
    event RatsWithdrawn(address indexed user, uint256[] spaceRatIds);
    event RewardPaid(address indexed user, uint256 reward);
}