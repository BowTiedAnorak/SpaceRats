pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "interfaces/IMintableERC20.sol";
import "interfaces/IMintableERC1155.sol";

/**
 * Staking contract for SpaceRat NFTs.
 * Mints Geodes & Iridium Tokens to stakers.
 * Functions are SpaceRat specific so in the future staking of Spaceships will be possible.
 * Staking spaceships will change the rate of rewards.
 * Based on: https://github.com/andreitoma8/Synthetix-ERC721-Staking/blob/master/contracts/ERC721Staking.sol
 */
contract AsteroidMine is ReentrancyGuard, ERC721Holder {

    // Variables to store the contract addresses of the NFTs & Tokens the
    // Asteroid Mine will interact with.
    IMintableERC20 public IRIDIUM_TOKEN;
    IMintableERC1155 public GEODE_NFT;
    IERC721 public SPACE_RAT_NFT;

    // Variables to keep track of state of the contract.
    uint256 public totalRatsStaked;
    // 1 Reward Per Second per Rat Staked
    uint256 public rewardRate = 1;
    // uint256 spaceshipBoostRate = 1;
    
    uint256 public GEODE_REWARD_AMOUNT = 604_800;

    // Variables to keep track of assets staked.
    // Mappings from Address to Token & vice versa.
    mapping(uint256 => address) public stakedAssets;
    mapping(address => uint256[]) public ratsStakedIds;
    // Required to find an NFT ID when a staker has multiple NFTs staked.
    // (ratsStakedIds is an array).
    mapping(uint256 => uint256) public spaceRatIdToIndex;
    
    // Stores the rewards a user has accrued.
    mapping(address => uint256) public userRewards;
    // Stores the date of the last time the user's rewards were updated.
    mapping(address => uint256) public userRewardsLastUpdate;

    constructor(address _iridiumToken, address _geodeNft, address _spaceRatNft) {
        IRIDIUM_TOKEN = IMintableERC20(_iridiumToken);
        GEODE_NFT = IMintableERC1155(_geodeNft);
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
            ratsStakedIds[msg.sender].push(spaceRatIds[i]);
            spaceRatIdToIndex[spaceRatIds[i]] = ratsStakedIds[msg.sender].length - 1;
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
            uint256[] storage userTokens = ratsStakedIds[msg.sender];
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

    // If the user has over 604_800 (1 month of staking 1 rat)
    // Then they can choose whether to mint a Geode or to mint the reward as Iridium Tokens.
    function claimRewardsAsIridiumTokens() public nonReentrant updateReward(msg.sender) {
        uint256 reward = userRewards[msg.sender];
        require(reward > 0, "No rewards to claim.");
        userRewards[msg.sender] = 0;
        IRIDIUM_TOKEN.mint(msg.sender, reward);
        emit RewardClaimedAsIridium(msg.sender, reward);
    }

    // A user can use their staking rewards to mine a Geode if they have over a certain threshold.
    // 604_800 is 1 week of staking 1 Rat
    function claimRewardsAsGeode() public nonReentrant updateReward(msg.sender) {
        uint256 reward = userRewards[msg.sender];
        require(reward >= GEODE_REWARD_AMOUNT, "Not enough rewards to claim a Geode.");
        userRewards[msg.sender] = reward - GEODE_REWARD_AMOUNT;
        GEODE_NFT.mint(msg.sender);
        emit RewardClaimedAsGeode(msg.sender);
    }

    // Withdraws all staked rats and claims the accrued rewards as Tokens.
    function withdrawAll() external {
        withdrawSpaceRats(ratsStakedIds[msg.sender]);
        claimRewardsAsIridiumTokens();
    }

    // Update the reward value a user is owed based on:
    //      (Number of Rats Staked * Number of seconds since last update) * Spaceship Boost.
    // Update lastUpdated value to current block timestamp.
    // The idea is:
    //  1. A Rat is staked - user rewards will be set to 0.
    //  2. A second Rat is staked (e.g. 30 seconds later) -
    //      30 seconds of rewards will be calculated based on a single Rat being staked.
    //      The Last Updated Timestamp will be updated for the user.
    //  3. Another Transaction is made that will affect rewards (e.g. staking, withdrawing, claiming)
    //      The staking of 2 Rats will be calculated based on current timestamp minus previous updated timestamp.
    //      This value will be added on to the existing value (from previously staking 1 Rat) and stored.
    //      The LastUpdatedTimestamp will be updated and the process continues.
    modifier updateReward(address user) {
        uint256 userRatsStaked = ratsStakedIds[user].length;
        uint256 currentReward = userRewards[user];
        uint256 lastReward = userRewardsLastUpdate[user];

        uint256 newReward = userRatsStaked * getSecondsSinceLastRewardUpdate(user) * rewardRate;
        userRewards[user] = currentReward + newReward;
        userRewardsLastUpdate[user] = block.timestamp;
        _;
    }

    function getSecondsSinceLastRewardUpdate(address user) public view returns (uint256) {
        uint256 prevTimestamp = userRewardsLastUpdate[user];
        if (prevTimestamp > 0) {
            return block.timestamp - prevTimestamp;
        } else {
            return 0;
        }
    }

    event RatsStaked(address indexed user, uint256[] spaceRatIds);
    event RatsWithdrawn(address indexed user, uint256[] spaceRatIds);
    event RewardClaimedAsIridium(address indexed user, uint256 reward);
    event RewardClaimedAsGeode(address indexed user);
}