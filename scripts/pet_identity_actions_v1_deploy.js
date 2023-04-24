const hre = require("hardhat");
const fs = require("fs");

async function main() {
  await hre.run("compile");

  const PetIdentityActions = await hre.ethers.getContractFactory(
    "PetIdentityActions"
  );
  const petIdentityActions = await PetIdentityActions.deploy();
  await petIdentityActions.deployed();
  console.log(
    "PetIdentityActions library deployed at:",
    petIdentityActions.address
  );
  await writeDeploymentInfo(petIdentityActions, "petIdentityActions.json");
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

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
