const hre = require("hardhat");
const { ethers } = hre;
const fs = require("fs");

async function main() {
  await hre.run("compile");

  const PieceNFT = await ethers.getContractFactory("PieceNFT");
  const pieceNFTImplementation = await PieceNFT.deploy();
  await pieceNFTImplementation.deployed();

  const Beacon = await hre.ethers.getContractFactory("Beacon");
  const beacon = await Beacon.deploy(pieceNFTImplementation.address);
  await beacon.deployed();
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
