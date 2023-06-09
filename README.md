Technical Requirements & High Level Contracts Design

- **SpaceRat**
    - ERC721 - PFP NFT Contract
    - Max Supply = 2,000
    - 1,000 Public Supply
    - 1,000 Whitelist Supply
    - Can be staked in AsteroidMine Contract
    - Public mint
        - No limit per address specified
        - Limited to 1,000
        - Can be called by any address
    - Whitelist Mint
        - No limit per address specified
        - Limited to 1,000
        - Can only be called by Whiltelist Contract
- **IridiumToken**
    - ERC20 - Token Contract
    - No limit on supply.
    - No initial supply.
    - Can only be minted by Geode & AsteroidMine Contracts.
- **AsteroidMine**
    - Staking Contract for SpaceRat NFTs
    - Mints Geodes & Iridium Tokens to stakers.
    - Will eventually need to also consider the Spaceships to determine mining speed.
- **Geode**
    - ERC1155 - Multiple of the same NFT
    - Minted by AsteroidMines
    - No cap on supply
    - Can be cracked open (burnt) for:
        - IridiumToken
            - 10% chance for 300,000
            - 88% chance for 50,000
        - WhitelistSpot (limited to 1,000) - 1% chance
        - SpaceshipKey - 1% chance + 1% once WhitelistSpots have minted out.
- **WhitelistSpot**
    - ERC1155 - Multiple of the ‘same’ NFT
    - Limited to 1,000
    - Can only be minted by Geode Contract
    - Can be burnt to mint a SpaceRat
- **SpaceshipKey**
    - ERC1155 - Multiple of the ‘same’ NFT.
    - No limit on supply.
    - Can only be minted by Geode Contract
    - Will eventually be used to mint a Spaceship NFT when ready.