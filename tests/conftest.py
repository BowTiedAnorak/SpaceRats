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
    # MAX_SUPPLY = 10
    # PUBLIC_SUPPLY = 5
    # WHITELIST_SUPPLY = 5
    return SpaceRat.deploy(10, 5, 5, {'from': accounts[0]})