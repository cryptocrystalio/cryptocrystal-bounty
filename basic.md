## Basics of CryptoCrystal:

CryptoCrystal is composed of 4 public facing contracts. 
Below we'll provide an overview on these contract


### CryptoCrystal - this contract managed the application logic.(Facade Contract)

Also referred as the main contract. This mediates the main operations, such as mine, melt, exchange and transfer of Crystals and Picaxe. 
And this contract handle Execution of the transaction below three contracts - Pickaxe,ExchangeBase,Crystal.

### Pickaxe(ERC20) -

This is the ERC20 token for mining the crystals.
PKX and ETH exchange rate is fixed.

### CrystalBase(ERC721)-

This is the ERC721 token as the crystal.
ERC721Token-"crystal", "CTL"

### ExchangeBase -

A marketplace where any user can put their Crystal　with the condition for any takers. It is also a marketplace where anyone can bit Crystals for some condisions.

---------------------------------------------------

## Basic Mining Rules

You can mine some crystal with Pkx(Erc20)

The amount of Crystal reserve, and discovery possibility is all determined by the smart contract.The amount of the mine　per times is subjected to the sullpy fnction.(The amount of suppy is gradualy reduced year by year like Bitcoin.)

A owner of a crystal can put their crystal to a trade exchange.

### Common functions
Here's what we expect to be the most usual flow, and what function are to be called below.

![alt](https://cdn-images-1.medium.com/max/1600/1*T5XWKNC3AzFPMCt6qP7X1w.jpeg)



Owner will mint Pkx token at first (Pickaxe Pickaxe())

### transaction

・user go an buy Pkx for mining(Main Sellable buyPickaxes())
・user can mine for new crystals  (Main mineCrystals())
・user can melt more than two of their crystals for getting bigger crystal (Main meltCrystals())
・user can put one of their crystals for the exchange (Main createExchange())
・user can bit the crystal which is exibit for the exchange(Main bitExchange())
・user can cancel an exibiton they started(Main cancelExchange())
・user can transfer a crystal they own to another user (Main transferFrom())

### call
・user can get a crystal data (CrystalBase  getCrystal())
・user can get thier all crystals data (CrystalBase getCrystals())
・user can check info of a crystal that is in the exibition (ExchangeBase getExchange())

Thank you for your reading!!
