# Time-Limited Tokens
Re-lease your apes.
## What its about
Time is the ultimate scarce resource. We have less of it every second. Time slicing is critical to ideas of fractional possession - allocating rights for a finite period allows resources to generate more value for more humans without requiring their growth or change.

The surging popularity of ERC721 tokens shows the opportunity for clear, simple standards for allocating property rights on the blockchain. Critical to any idea of property rights is the ability to lend or lease an asset for a limited period of time. Blockchain has a unique opportunity to permit these transactions without trust or a third party guarantor because of the public, immutable record.

However, ERC721 and related standards do not provide functionality to enable leasing of NFTs or other assets for a specific period.

That's why we devoted our hackathon period to defining a simple, supple interface for time-slicing assets and expressing who has possession as a lessee at which point in time. 

[Watch the video from our Web3Con Hackathon submission](https://www.loom.com/share/6992b9306f134e9fa19ab62bac53c79c?sharedAppSource=personal_library)
## EIP
Read our attached [Ethereum Improvement Proposal](./eip-time-limited-tokens.md) in `eip-time-limited-tokens.md`

## How to Install
To add the interface to your dapp,
1. `npm i time-limited-tokens` or `yarn add time-limited-tokens`
2. In solidity, `import "time-limited-tokens/contracts/ITimeLimitedTokens.sol"`
3. In your dapp, you can access the abi via `import { abi } from "time-limited-tokens"` or `const { abi } = require("time-limited-tokens")` 
4. In ethers or web3, use the abi to make your contract communication easy
## Demonstration Dapp
See how it works 

## License and attribution
We believe in abundance. We hope that this project can form an ERC standard to make time-slicing assets easier, and that the code here will give you a head start. Please use it, make it better, and let us know! 

## Team
1. Ray Deck ([@rhdeck](https://github.com/rhdeck))
2. Akshay Rakheja ([@akshay-rakheja](https://github.com/akshay-rakheja))
3. Robert Reinhart ([@robertreinhart](https://github.com/robertreinhart))

## Early Contributors
1. Radek Sienkiewicz ([@sabon](https://github.com/sabon))
2. Naiyoma Aurelia ([@naiyoma](https://github.com/naiyoma))

## Thanks
This project got its start at the [Web3Con](https://web3con.dev) [Hackathon](https://web3con.dev/hackathon) put on by [Developer DAO](https://developerdao.com). Many thanks to them for putting this event together and giving us the chance to work on a fun, meaningful project for the web3 community! 
