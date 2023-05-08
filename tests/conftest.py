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
    return SpaceRat.deploy({'from': accounts[0]})