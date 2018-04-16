import ether from './helpers/ether';
import sendTransaction from './helpers/sendTransaction';
import EVMRevert from './helpers/EVMRevert';

const BigNumber = web3.BigNumber;

require('chai')
    .use(require('chai-as-promised'))
    .use(require('chai-bignumber')(BigNumber))
    .should();

const CryptoCrystal = artifacts.require("CryptoCrystal");
const Pickaxe = artifacts.require("Pickaxe");
const CrystalBase = artifacts.require("CrystalBase");
const ExchangeBase = artifacts.require("ExchangeBase");

const tokensToCrystals = (tokens) => {
    return tokens[0].map((e, i) => {
        return {
            tokenId: e.toNumber(),
            gene: tokens[1][i].toNumber(),
            kind: tokens[2][i].toNumber(),
            weight: tokens[3][i].toNumber()
        }
    });
}

let cryptoCrystalInstance;
let pickaxeInstance;
let crystalInstance;
let exchangeInstance;

(async () => {
    cryptoCrystalInstance = await CryptoCrystal.deployed();
    pickaxeInstance = await Pickaxe.deployed();
    crystalInstance = await CrystalBase.deployed();
    exchangeInstance = await ExchangeBase.deployed();
})();

contract("CryptoCrystal(Scenario Test)", async (accounts) => {
    const owner = accounts[0];
    const user = accounts[1];
    const initialSupply = 20000000;
    const pickaxesAmount = 3;

    describe('constructor', function() {
        it('increases pickaxes of owner by initialSupply', async function() {
            const balance = await pickaxeInstance.balanceOf(owner);
            balance.should.be.bignumber.equal(initialSupply);
        });
    })

    describe('buy pickaxes', function() {
        before(async function() {
            await sendTransaction(cryptoCrystalInstance, user, ether(0.005 * pickaxesAmount));
        });

        it('reduces pickaxes of owner', async function() {
            const balanceOfOwner = await pickaxeInstance.balanceOf(owner);
            balanceOfOwner.should.be.bignumber.equal(initialSupply - pickaxesAmount);
        });

        it('increases pickaxes of user', async function() {
            const balanceOfUser = await pickaxeInstance.balanceOf(user);
            balanceOfUser.should.be.bignumber.equal(pickaxesAmount);
        });
    });

    describe('mine crystals', function() {
        before(async function() {
            for(let i = 0; i < pickaxesAmount; i++) {
                // we get pickaxesAmount crystals at least.
                await cryptoCrystalInstance.mineCrystals(1, {from : user});
            }
        });

        it('burns all pickaxes of user', async function() {
            const balanceOfUser = await pickaxeInstance.balanceOf(user);
            balanceOfUser.should.be.bignumber.equal(0);
        });

        it('gives pickaxesAmount crystal to user at least', async function() {
            const crystalBalance = await crystalInstance.balanceOf(user);
            crystalBalance.should.be.bignumber.least(pickaxesAmount);
        });
    });

    describe('create exchange', function() {
        before(async function() {
            const tokens = await crystalInstance.getCrystals(user);
            this.tokenId = tokensToCrystals(tokens)[0].tokenId;
            await cryptoCrystalInstance.createExchange(this.tokenId, 0, 1000, {from: user});
        });

        it('creates exchange', async function() {
            const id = 0; // first exchange id is 0
            const exchange = await exchangeInstance.getExchange(id);
            exchange[0].should.be.equal(user);
            exchange[1].should.be.bignumber.equal(this.tokenId);
        });
    });

    describe('cancel exchange', function() {
        before(async function() {
            const id = 0; // first exchange id is 0
            await cryptoCrystalInstance.cancelExchange(id, {from :user});
        });

        it('cancels exchange', async function() {
            const id = 0; // first exchange id is 0
            await exchangeInstance.getExchange(id).should.be.rejectedWith(EVMRevert);
        });
    });
});