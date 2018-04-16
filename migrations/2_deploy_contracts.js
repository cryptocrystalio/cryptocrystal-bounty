const CryptoCrystal = artifacts.require("CryptoCrystal");
const Pickaxe = artifacts.require("Pickaxe");
const CrystalBase = artifacts.require("CrystalBase");
const ExchangeBase = artifacts.require("ExchangeBase");

module.exports = function(deployer) {
    const wallet = 0; // set our wallet in production

    deployer.then(async () => {
        await deployer.deploy(Pickaxe);
        await deployer.deploy(CrystalBase);
        await deployer.deploy(ExchangeBase);
        await deployer.deploy(CryptoCrystal, Pickaxe.address, CrystalBase.address, ExchangeBase.address, wallet);
        const deployedPickaxe = await Pickaxe.deployed();
        const deployedCrystalBase = await CrystalBase.deployed();
        const deployedExchangeBase = await ExchangeBase.deployed();
        await deployedPickaxe.setAcceptable(CryptoCrystal.address);
        await deployedCrystalBase.setAcceptable(CryptoCrystal.address);
        await deployedExchangeBase.setAcceptable(CryptoCrystal.address);
    });
};
