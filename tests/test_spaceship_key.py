#!/usr/bin/python3
import brownie

def test_spaceship_key_mint(accounts, spaceship_key):
    spaceship_key.setGeodeContract(accounts[1], {"from": accounts[0]})
    spaceship_key.mint(accounts[2], {"from": accounts[1]})
    assert spaceship_key.balanceOf(accounts[2], 1)
