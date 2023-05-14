#!/usr/bin/python3
import pytest

@pytest.fixture(scope='function', autouse=True)
def isolate(fn_isolation):
    # perform a chain rewind after completing each test.
    pass

@pytest.fixture(scope="module")
def token(IridiumToken, accounts):
    return IridiumToken.deploy({'from': accounts[0]})

@pytest.fixture(scope="module")
def space_rat(SpaceRat, accounts):
    # Set the following max supplies for testing:
    # PUBLIC_SUPPLY = 5
    # WHITELIST_SUPPLY = 5
    return SpaceRat.deploy(5, 5, {'from': accounts[0]})

@pytest.fixture(scope="module")
def asteroid_mine(AsteroidMine, accounts, token, space_rat):
    mine = AsteroidMine.deploy(token, space_rat, space_rat, {'from': accounts[0]})
    token.setAsteroidContract(mine)
    return mine

@pytest.fixture(scope="module")
def geode(Geode, accounts, token):
    deployed_geode = Geode.deploy({"from": accounts[0]})
    deployed_geode.setIridiumTokenContract(token)
    token.setGeodeContract(deployed_geode)
    return deployed_geode

@pytest.fixture(scope="module")
def rat_whitelist(SpaceRatWhitelistSpot, accounts):
    whitelist = SpaceRatWhitelistSpot.deploy(5, {"from": accounts[0]})
    return whitelist

@pytest.fixture(scope="module")
def spaceship_key(SpaceshipKey, accounts):
    return SpaceshipKey.deploy({"from": accounts[0]})