import EVMRevert from './helpers/EVMRevert';

const BigNumber = web3.BigNumber;

require('chai')
    .use(require('chai-as-promised'))
    .use(require('chai-bignumber')(BigNumber))
    .should();

const Pickaxe = artifacts.require("Pickaxe");

contract("Pickaxe", async (accounts) => {
    beforeEach(async function() {
        this.owner = accounts[0];
        this.acceptable = accounts[1];
        this.instance = await Pickaxe.new();
        this.instance.setAcceptable(this.acceptable, {from: this.owner});
    });

    describe('transferFromOwner', function() {
       it('is called by acceptable', async function() {
           const amount = 10;
           const result = await this.instance.transferFromOwner(this.owner, amount, {from: this.acceptable});

           result.logs[0].event.should.be.equal("Transfer");
           result.logs[0].args.value.should.be.bignumber.equal(amount);
       });

       it('is not called directly', async function() {
           const amount = 10;
           await this.instance.transferFromOwner(this.owner, amount, {from: this.owner}).should.be.rejectedWith(EVMRevert);;
       });
    });

    describe('burn', function() {
        it('is called by acceptable', async function() {
            const amount = 10;
            const result = await this.instance.burn(this.owner, amount, {from: this.acceptable});

            result.logs[0].event.should.be.equal("Burn");
            result.logs[0].args.value.should.be.bignumber.equal(amount);
        });

        it('is not called directly', async function() {
            const amount = 10;
            await this.instance.burn(this.owner, amount, {from: this.owner}).should.be.rejectedWith(EVMRevert);;
        });
    });
});