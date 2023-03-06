# BUK Smartcontract
BUK is a decentralized, open chain globally accessible protocol, making the conventional hotel inventory distribution and booking experience more flexible and decentralized to benefit all participants, travelers, hotel owners. 

With BUK, when you book a hotel room you get an NFT which represents the right to stay in that particular room of that hotel for a specific night. However, unlike a traditional booking this NFT can be traded and sold to someone else. Hotels and intermediaries get commissions every time a room night NFT is traded, end customers get the flexibility to Resell, instead of canceling and since all transactions are on the blockchain, it makes the process transparent.

BUK protocol shall be build as an independent Protocol layer, and separate products which operate on top of the protocol. Being an open protocol, developers will be able to build their respective products on top of the protocol.

Historical version of our MVP smart contract can be read here: https://mumbai.polygonscan.com/address/0xcdb37633625acf33b32426f7030307180f12f62e#code

### BUK Protocol target architecture
![BUK Protocol target architecture](/img/BUK-smartcontract-target-architecture.png?raw=true "BUK Protocol target architecture")
The BUK protocol is a smart contract deployed on the Polygon Ethereum blockchain which can be invoked by various dApps deployed by Hotels and Travel vendors. Key functions of the BUK protocol are shown / explained below.

#### 1. Register Hotel 
![Register Hotel architecture](/img/BUK-smartcontract-register-hotel.png?raw=true "Register Hotel architecture")

This feature allows a new hotel to list tokenised inventory on the BUK protocol

#### 2. Book room 
![Book room architecture](/img/BUK-smartcontract-room-booking-user-journey.png?raw=true "Book room architecture")

This is the first 'booking' transaction which books the room in the hotel systems and tokenises it as an NFT on the blockchain. The NFT is minted and made ready for secondary sale. All NFTs shall be stored on NFT.Storage (Filecoin storage network). For enhanced performance for web2 based systems, BUK plans to use TheGraph.

#### 3. Trading of NFTs 
![NFT Trading architecture](/img/BUK-smartcontract-NFT-sale.png?raw=true "NFT Trading architecture")

This enables the wallet holding the NFT to list the NFT for sale, and another user to then buy this NFT by executing a marketplace transaction.

#### 4. Pre-Checkin 
![Pre-checkin architecture](/img/BUK-smartcontract-pre-checkin-NFT-disfunctional.png?raw=true "Pre-checkin architecture")

This confirms that the holder of the NFT will be staying in the hotel room and hence disables any further sale / transfer / trading of the NFT.

#### 5. Cancellation of bookings
![Cancellation architecture](/img/BUK-smartcontract-booking-cancellation.png?raw=true "Cancellation architecture")

This is provided to allow tokenised bookings to be cancelled just like normal bookings if the user is unable to find a buyer. This will also be used by hotels and the admin in case of any force majeur conditions to cancel bookings. 

#### 6. Admin functionalities 
![Admin functionalities](/img/BUK-smartcontract-admin-functions.png?raw=true "Admin functionalities")

Certain power user functions which will be required for the smart contract to operate.

## !IGNORE Boilerplate Test from Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, and a script that deploys that contract.

Try running some of the following tasks:

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat run scripts/deploy.ts
```
