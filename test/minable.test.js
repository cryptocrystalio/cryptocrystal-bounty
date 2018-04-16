import EVMRevert from './helpers/EVMRevert';

const BigNumber = web3.BigNumber;

require('chai')
    .use(require('chai-as-promised'))
    .use(require('chai-bignumber')(BigNumber))
    .should();

const Minable = artifacts.require("Minable");

contract("Minable", async (accounts) => {
    beforeEach(async function() {
        this.instance = await Minable.new();
        this.secondsPerBlock = await this.instance.secondsPerBlock();
    });


    describe('_getRandomKinds', function() {
       it('returns kinds', async function() {
           const kinds = await this.instance._getRandomKinds([100, 1000, 10000], 3, 0);
           kinds[0].should.have.lengthOf(3);
       });
    });

    describe('_getRandomWeights', function() {
        it('returns weights', async function() {
            const weights = await this.instance._getRandomWeights(3, 1000, 0);
            weights[0].should.have.lengthOf(3);
            weights[0].forEach((weight) => {
                weight.should.be.bignumber.above(0);
            });
        })
    });

    describe('_decideCrystals', function() {
        it('returns crystals', async function() {
            const crystals = await this.instance._decideCrystals([100, 1000, 10000], 0);
            crystals[0].should.have.length.least(1);
            crystals[1].should.have.length.least(1);
            crystals[1].forEach((weight) => {
                weight.should.be.bignumber.above(0);
            });
        });
    });
});