from brownie import IridiumToken, accounts

def deploy_iridium_token():
    iridium_token = IridiumToken.deploy({"from": accounts[0]})
    return iridium_token

def main():
    deploy_iridium_token()

main()