#!/usr/bin/python3
import brownie

def test_mint(accounts, geode):
    geode.setAsteroidMineContract(accounts[0], {'from': accounts[0]})
    geode.mint(accounts[1], {"from": accounts[0]})
    assert geode.balanceOf(accounts[1], 1) == 1
    geode.mint(accounts[1], {"from": accounts[0]})
    assert geode.balanceOf(accounts[1], 1) == 2

def test_mint_revert(accounts, geode):
    with brownie.reverts("Only the Asteroid Mine Contract can call this function."):
        geode.mint(accounts[1], {"from": accounts[2]})

def test_crack_open(accounts, geode, token):
    geode.setAsteroidMineContract(accounts[0], {'from': accounts[0]})
    geode.mint(accounts[1], {"from": accounts[0]})
    geode.crackOpen({"from": accounts[1]})
    assert geode.balanceOf(accounts[1], 1) == 0
    assert token.balanceOf(accounts[1]) == 100

def test_crack_open_revert(accounts, geode):
    with brownie.reverts("Caller must have a Geode to open."):
        geode.crackOpen({"from": accounts[2]})