#!/usr/bin/python3
import brownie

def test_only_owner(accounts, token):
    with brownie.reverts("Only the owner can call this function."):
        token.revokeOwnership({'from': accounts[1]})

def test_set_geode_contract(accounts, token):
    original_geode_contract = token.GEODE_CONTRACT()
    token.setGeodeContract(accounts[1], {'from': accounts[0]})
    geode_contract = token.GEODE_CONTRACT()
    assert geode_contract != original_geode_contract
    assert geode_contract == accounts[1]

def test_set_asteroid_contract(accounts, token):
    original_asteroid_contract = token.ASTEROID_CONTRACT()
    token.setAsteroidContract(accounts[1], {'from': accounts[0]})
    asteroid_contract = token.ASTEROID_CONTRACT()
    assert asteroid_contract != original_asteroid_contract
    assert asteroid_contract == accounts[1]

def test_revoke_ownership(accounts, token):
    original_owner = token.owner()
    token.revokeOwnership({'from': accounts[0]})
    owner = token.owner()
    assert original_owner != owner
    assert owner == "0x0000000000000000000000000000000000000000"

def test_mint(accounts, token):
    original_balance = token.balanceOf(accounts[5])
    token.setAsteroidContract(accounts[1], {'from': accounts[0]})
    token.mint(accounts[5], 1, {'from': accounts[1]})
    new_balance = token.balanceOf(accounts[5])
    assert (new_balance - original_balance) == 1