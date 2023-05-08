#!/usr/bin/python3
import brownie

def test_set_whitelist_contract(accounts, space_rat):
    original_whitelist_contract = space_rat.WHITELIST_CONTRACT()
    space_rat.setWhitelistContract(accounts[1], {'from': accounts[0]})
    whitelist_contract = space_rat.WHITELIST_CONTRACT()
    assert whitelist_contract != original_whitelist_contract
    assert whitelist_contract == accounts[1]

def test_set_multiple_whitelist_contracts(accounts, space_rat):
    space_rat.setWhitelistContract(accounts[1], {'from': accounts[0]})
    with brownie.reverts("Whitelist Contract Address has already been set."):
        space_rat.setWhitelistContract(accounts[2], {'from': accounts[0]})

def test_public_mint(accounts, space_rat):
    space_rat.publicMint(accounts[1], {"from": accounts[1]})
    assert space_rat.balanceOf(accounts[1]) == 1
    assert space_rat.ownerOf(1) == accounts[1]

def test_public_mint_maximum(accounts, space_rat):
    for i in range(0, 5):
        print(i)
        space_rat.publicMint(accounts[1], {"from": accounts[1]})
    assert space_rat.balanceOf(accounts[1]) == 5
    
    with brownie.reverts("Maximum Public mint reached."):
        space_rat.publicMint(accounts[1], {"from": accounts[1]})

def test_whitelist_mint_maximum(accounts, space_rat):
    space_rat.setWhitelistContract(accounts[1], {'from': accounts[0]})
    for i in range(0, 5):
        print(i)
        space_rat.whitelistMint(accounts[1], {"from": accounts[1]})
    assert space_rat.balanceOf(accounts[1]) == 5
    
    with brownie.reverts("Maximum Whitelist mint reached."):
        space_rat.whitelistMint(accounts[1], {"from": accounts[1]})