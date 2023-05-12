#!/usr/bin/python3
import brownie

def test_mint(accounts, rat_whitelist):
    rat_whitelist.setGeodeContract(accounts[1], {"from": accounts[0]})
    rat_whitelist.mint(accounts[2], {"from": accounts[1]})
    assert rat_whitelist.balanceOf(accounts[2], 1)

def test_mint_exceed_supply(accounts, rat_whitelist):
    rat_whitelist.setGeodeContract(accounts[1], {"from": accounts[0]})
    for i in range(5):
        rat_whitelist.mint(accounts[2], {"from": accounts[1]})
    
    assert rat_whitelist.balanceOf(accounts[2], 1) == 5

    with brownie.reverts("Maximum supply reached."):
        rat_whitelist.mint(accounts[2], {"from": accounts[1]})

def test_mint_space_rat(accounts, rat_whitelist, space_rat):
    rat_whitelist.setGeodeContract(accounts[1], {"from": accounts[0]})
    rat_whitelist.setSpaceRatContract(space_rat, {"from": accounts[0]})
    rat_whitelist.mint(accounts[2], {"from": accounts[1]})
    space_rat.setWhitelistContract(rat_whitelist, {"from": accounts[0]})

    rat_whitelist.mintSpaceRat({"from": accounts[2]})
    assert rat_whitelist.balanceOf(accounts[2], 1) == 0
    assert space_rat.balanceOf(accounts[2]) == 1

def test_mint_space_rat_revert(accounts, rat_whitelist):
    with brownie.reverts("No whitelist spots to mint a Space Rat."):
        rat_whitelist.mintSpaceRat({"from": accounts[2]})