import EVMRevert from './helpers/EVMRevert';

const BigNumber = web3.BigNumber;

require('chai')
    .use(require('chai-as-promised'))
    .use(require('chai-bignumber')(BigNumber))
    .should();

const Crystal = artifacts.require("CrystalBase");

contract("Pickaxe", async (accounts) => {
    beforeEach(async function() {
        this.instance = await Crystal.new();
    });

    describe('mint', function() {
       it('is not called directly', async function() {
           const from = accounts[0];
           await this.instance.mint(from, 1, 1, 1, {from: from}).should.be.rejectedWith(EVMRevert);
       });
    });

    describe('burn', function() {
        it('is not called directly', async function() {
            const from = accounts[0];
            await this.instance.burn(from, 10, {from: from}).should.be.rejectedWith(EVMRevert);
        });
    });
});