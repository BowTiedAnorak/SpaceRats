#!/usr/bin/python3
import brownie

def test_stake_space_rat(accounts, space_rat, asteroid_mine):
    # Arrange
    space_rat.publicMint(accounts[1], {"from": accounts[1]})
    rat_id = 1
    space_rat.approve(asteroid_mine, rat_id, {'from': accounts[1]})
    
    # Act
    asteroid_mine.stakeSpaceRats([rat_id], {'from': accounts[1]})

    # Assert
    assert space_rat.ownerOf(rat_id) == asteroid_mine.address
    assert asteroid_mine.totalRatsStaked() == 1
    assert asteroid_mine.stakedAssets(rat_id) == accounts[1]
    # assert asteroid_mine.ratsStakedIds(accounts[1]) == [rat_id]

def test_stake_space_rats(accounts, space_rat, asteroid_mine):
    space_rat.publicMint(accounts[1], {"from": accounts[1]})
    space_rat.publicMint(accounts[1], {"from": accounts[1]})
    rat_ids = [1, 2]
    space_rat.approve(asteroid_mine, rat_ids[0], {'from': accounts[1]})
    space_rat.approve(asteroid_mine, rat_ids[1], {'from': accounts[1]})
    
    asteroid_mine.stakeSpaceRats(rat_ids, {'from': accounts[1]})

    assert space_rat.ownerOf(rat_ids[0]) == asteroid_mine.address
    assert space_rat.ownerOf(rat_ids[1]) == asteroid_mine.address
    assert asteroid_mine.totalRatsStaked() == 2
    assert asteroid_mine.stakedAssets(rat_ids[0]) == accounts[1]
    assert asteroid_mine.stakedAssets(rat_ids[1]) == accounts[1]

def test_withdraw_space_rat(accounts, space_rat, asteroid_mine):
    space_rat.publicMint(accounts[1], {"from": accounts[1]})
    rat_id = 1
    space_rat.approve(asteroid_mine, rat_id, {'from': accounts[1]})
    asteroid_mine.stakeSpaceRats([rat_id], {'from': accounts[1]})
    
    asteroid_mine.withdrawSpaceRats([rat_id], {'from': accounts[1]})

    assert space_rat.ownerOf(rat_id) == accounts[1]
    assert asteroid_mine.totalRatsStaked() == 0

def test_withdraw_space_rats(accounts, space_rat, asteroid_mine):
    space_rat.publicMint(accounts[1], {"from": accounts[1]})
    space_rat.publicMint(accounts[1], {"from": accounts[1]})
    rat_ids = [1, 2]
    space_rat.approve(asteroid_mine, rat_ids[0], {'from': accounts[1]})
    space_rat.approve(asteroid_mine, rat_ids[1], {'from': accounts[1]})
    asteroid_mine.stakeSpaceRats(rat_ids, {'from': accounts[1]})
    
    asteroid_mine.withdrawSpaceRats(rat_ids, {'from': accounts[1]})

    assert space_rat.ownerOf(rat_ids[0]) == accounts[1]
    assert space_rat.ownerOf(rat_ids[1]) == accounts[1]
    assert asteroid_mine.totalRatsStaked() == 0

def test_get_seconds_since_last_reward_update(accounts, asteroid_mine, space_rat, chain):
    space_rat.publicMint(accounts[1], {"from": accounts[1]})
    rat_id = 1
    space_rat.approve(asteroid_mine, rat_id, {'from': accounts[1]})
    asteroid_mine.stakeSpaceRats([rat_id], {'from': accounts[1]})
    chain.sleep(5)
    chain.mine(1)
    seconds_since_reward_update = asteroid_mine.getSecondsSinceLastRewardUpdate(accounts[1])
    assert seconds_since_reward_update == 5

def test_claim_rewards_as_tokens(accounts, asteroid_mine, space_rat, chain, token):
    space_rat.publicMint(accounts[1], {"from": accounts[1]})
    rat_id = 1
    space_rat.approve(asteroid_mine, rat_id, {'from': accounts[1]})
    asteroid_mine.stakeSpaceRats([rat_id], {'from': accounts[1]})
    seconds_staked = 5
    chain.sleep(seconds_staked)
    chain.mine(1)

    asteroid_mine.claimRewardsAsIridiumTokens({'from': accounts[1]})
    assert asteroid_mine.userRewards(accounts[1]) == 0

    expected_tokens = asteroid_mine.rewardRate() * seconds_staked
    assert token.balanceOf(accounts[1]) == expected_tokens

# def test_claim_rewards_as_geode(accounts, asteroid_mine, space_rat, geode, chain):
#     geode.setAsteroidMineContract(asteroid_mine, {"from": accounts[0]})
#     space_rat.publicMint(accounts[1], {"from": accounts[1]})
#     rat_id = 1
#     space_rat.approve(asteroid_mine, rat_id, {"from": accounts[1]})
#     asteroid_mine.stakeSpaceRats([rat_id], {'from': accounts[1]})
#     seconds_staked = 700_000
#     chain.sleep(seconds_staked)
#     chain.mine(1)
#     tokens_before = asteroid_mine.userRewards(accounts[1])
#     asteroid_mine.claimRewardsAsGeode({'from': accounts[1]})
#     tokens_after = asteroid_mine.userRewards(accounts[1])
#     assert tokens_after - tokens_before == 604_800
#     assert geode.balanceOf(accounts[1]) == 1
    
def test_reward_calculation(accounts, asteroid_mine, space_rat, chain):
    rats_staked = 2
    seconds_staked = 5
    space_rat.publicMint(accounts[1], {"from": accounts[1]})
    space_rat.publicMint(accounts[1], {"from": accounts[1]})
    space_rat.approve(asteroid_mine, 1, {'from': accounts[1]})
    space_rat.approve(asteroid_mine, 2, {'from': accounts[1]})
    asteroid_mine.stakeSpaceRats([1, 2], {'from': accounts[1]})
    chain.sleep(seconds_staked)
    chain.mine(1)
    asteroid_mine.withdrawSpaceRats([1,2], {'from': accounts[1]})
    expected_tokens = asteroid_mine.rewardRate() * rats_staked * seconds_staked
    assert asteroid_mine.userRewards(accounts[1]) == expected_tokens