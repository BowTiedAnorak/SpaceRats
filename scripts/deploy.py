from brownie import IridiumToken, SpaceRat, Geode, AsteroidMine, SpaceRatWhitelistSpot, SpaceshipKey, accounts

WHITELIST_SPOT_MAX_SUPPLY = 1_000
SPACERAT_PUBLIC_MAX_SUPPLY = 1_000
SPACERAT_WHITELIST_MAX_SUPPLY = 1_000

DEPLOYER = {"from": accounts[0]}

def deploy_iridium_token():
    iridium_token = IridiumToken.deploy(DEPLOYER)
    return iridium_token

def deploy_space_rat_nft():
    space_rat_nft = SpaceRat.deploy(SPACERAT_PUBLIC_MAX_SUPPLY, SPACERAT_WHITELIST_MAX_SUPPLY, DEPLOYER)
    return space_rat_nft

def deploy_geode_nft():
    geode = Geode.deploy(DEPLOYER)
    return geode

def deploy_asteroid_mine(token, geode, space_rat):
    mine = AsteroidMine.deploy(token, geode, space_rat, DEPLOYER)
    return mine

def deploy_whitelist_spot():
    whitelist_spot = SpaceRatWhitelistSpot.deploy(WHITELIST_SPOT_MAX_SUPPLY, DEPLOYER)
    return whitelist_spot

def deploy_spaceship_key():
    spaceship_key = SpaceshipKey.deploy(DEPLOYER)
    return spaceship_key

def configure_token(token, geode, mine):
    token.setGeodeContract(geode, DEPLOYER)
    token.setAsteroidContract(mine, DEPLOYER)

def configure_space_rat(space_rat, whitelist_spot):
    space_rat.setWhitelistContract(whitelist_spot, DEPLOYER)

def configure_geode(geode, token, mine):
    geode.setIridiumTokenContract(token, DEPLOYER)
    geode.setAsteroidMineContract(mine, DEPLOYER)

def configure_whitelist_spot(whitelist_spot, geode, space_rat):
    whitelist_spot.setGeodeContract(geode, DEPLOYER)
    whitelist_spot.setSpaceRatContract(space_rat, DEPLOYER)

def configure_spaceship_key(spaceship_key, geode):
    spaceship_key.setGeodeContract(geode, DEPLOYER)

def main():
    token = deploy_iridium_token()
    space_rat = deploy_space_rat_nft()
    geode = deploy_geode_nft()
    mine = deploy_asteroid_mine(token, geode, space_rat)
    whitelist_spot = deploy_whitelist_spot()
    spaceship_key = deploy_spaceship_key()

    configure_token(token, geode, mine)
    configure_space_rat(space_rat, whitelist_spot)
    configure_geode(geode, token, mine)
    configure_whitelist_spot(whitelist_spot, geode, space_rat)
    configure_spaceship_key(spaceship_key, geode)

main()