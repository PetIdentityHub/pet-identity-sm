const hre = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();
  const name = "PetProfileNFT";
  const symbol = "PPNFT";
  const owner = "0xd20A336057A940BCae44554B1B5CbC2C716bED5d";
  const service = "0xd20A336057A940BCae44554B1B5CbC2C716bED5d";

  console.log("Deploying contracts with the account:", deployer.address);

  const PetProfileNFT = await ethers.getContractFactory("PetProfileNFT");
  const petProfileNFT = await upgrades.deployProxy(
    PetProfileNFT,
    [owner, service, name, symbol],
    {
      initializer: "initialize",
    }
  );

  console.log("PetProfileNFT deployed to:", petProfileNFT.address);
  await writeDeploymentInfo(petProfileNFT, "petProfileNFT.json");
}

async function writeDeploymentInfo(contract, filename = "") {
  const data = {
    network: hre.network.name,
    contract: {
      address: contract.address,
      signerAddress: contract.signer.address,
      abi: contract.interface.format(),
    },
  };
  const content = JSON.stringify(data, null, 2);
  await fs.writeFile(filename, content, { encoding: "utf-8" });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
