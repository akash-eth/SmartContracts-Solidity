const Dai = artifacts.require("Dai");
const DefiProject = artifacts.require("DefiProject");

module.exports = async function (deployer, _network, accounts) {
  await deployer.deploy(Dai);
  const dai = await Dai.deployed();

  await deployer.deploy(DefiProject, dai.address);
  const defiProject = await DefiProject.deployed();
  await dai.getFaucet(defiProject.address, 100);
  await defiProject.transferToken(accounts[1], 100);

  const balance0 = await dai.balanceOf(defiProject.address);
  const balance1 = await dai.balanceOf(accounts[1]);

  console.log(balance0.toString());
  console.log(balance1.toString());
};