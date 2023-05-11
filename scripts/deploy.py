from brownie import IridiumToken, SpaceRat, accounts

def deploy_iridium_token():
    iridium_token = IridiumToken.deploy({"from": accounts[0]})
    return iridium_token

def deploy_space_rat_nft():
    space_rat_nft = SpaceRat.deploy({"from": accounts[0]})
    return space_rat_nft

def main():
    deploy_iridium_token()
    deploy_space_rat_nft()
    # TODO: Add deployment of asteroid mine - take in above 2 contracts as parameters.

main()