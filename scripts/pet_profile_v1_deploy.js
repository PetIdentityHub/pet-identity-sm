const hre = require("hardhat");
const fsPromises = require("fs").promises;

async function main() {
  const [deployer] = await ethers.getSigners();
  const namePetProfile = "PetProfileNFT";
  const symbolPetProfile = "PetNFT";
  const ownerPetProfile = "0xd20A336057A940BCae44554B1B5CbC2C716bED5d";
  const servicePetProfile = "0xd20A336057A940BCae44554B1B5CbC2C716bED5d";

  console.log("Deploying contracts with the account:", deployer.address);

  //PetProfileNFT deploy
  const PetProfileNFT = await ethers.getContractFactory("PetProfileNFT", {
    libraries: {
      PetIdentityActions: "0x2a108bcf9eA00B14A12816a81Bc8Ea22d1CFf643",
    },
  });
  const petProfileNFT = await upgrades.deployProxy(
    PetProfileNFT,
    [ownerPetProfile, servicePetProfile, namePetProfile, symbolPetProfile],
    {
      unsafeAllow: ["external-library-linking"],
      initializer: "initialize",
    }
  );

  console.log("PetProfileNFT deployed to:", petProfileNFT.address);
  await writeDeploymentInfo(petProfileNFT, "petProfileNFT");
}

async function writeDeploymentInfo(
  contract,
  filename = "",
  extension = "json"
) {
  const data = {
    network: hre.network.name,
    contract: {
      address: contract.address,
      signerAddress: contract.signer.address,
      abi: contract.interface.format(),
    },
  };
  const content = JSON.stringify(data, null, 2);
  await fsPromises.writeFile(
    "deployment_logs/".concat(
      filename,
      "_",
      new Date().toISOString().slice(0, 10),
      ".",
      extension
    ),
    content,
    {
      encoding: "utf-8",
    }
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
