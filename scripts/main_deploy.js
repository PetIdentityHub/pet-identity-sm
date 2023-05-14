const hre = require("hardhat");
const fsPromises = require("fs").promises;

async function main() {
  await hre.run("compile");

  const [deployer] = await ethers.getSigners();
  //PetProfile initial values
  const namePetProfile = "PetProfileNFT";
  const symbolPetProfile = "PetNFT";
  const ownerPetProfile = "0xd20A336057A940BCae44554B1B5CbC2C716bED5d";
  const servicePetProfile = "0xd20A336057A940BCae44554B1B5CbC2C716bED5d";

  //PieceIssuer initial values
  const nameIssuer = "PieceIssuerNFT";
  const symbolIssuer = "PiNFT";
  const ownerIssuer = "0xd20A336057A940BCae44554B1B5CbC2C716bED5d";
  const serviceIssuer = "0xd20A336057A940BCae44554B1B5CbC2C716bED5d";

  //Beacon initial values
  const ownerBeacon = "0xd20A336057A940BCae44554B1B5CbC2C716bED5d";

  console.log("Deploying contracts with the account:", deployer.address);

  //PetIdentityActions deploy
  const PetIdentityActions = await hre.ethers.getContractFactory(
    "PetIdentityActions"
  );
  const petIdentityActions = await PetIdentityActions.deploy();
  await petIdentityActions.deployed();
  console.log(
    "PetIdentityActions library deployed at:",
    petIdentityActions.address
  );
  await writeDeploymentInfo(petIdentityActions, "petIdentityActions");

  //PetProfileNFT deploy
  const PetProfileNFT = await ethers.getContractFactory("PetProfileNFT", {
    libraries: {
      PetIdentityActions: petIdentityActions.address,
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

  console.log("Deploying contracts with the account:", deployer.address);

  const PieceNFT = await ethers.getContractFactory("IdentityPiecesNFT");
  const pieceNFTImplementation = await PieceNFT.deploy();
  await pieceNFTImplementation.deployed();
  console.log(
    "PieceNFT implementation deployed at:",
    pieceNFTImplementation.address
  );

  await writeDeploymentInfo(pieceNFTImplementation, "identityPieceNFT");

  const Beacon = await hre.ethers.getContractFactory("UpgradeableBeacon");
  const beacon = await Beacon.deploy(
    pieceNFTImplementation.address,
    ownerBeacon
  );
  await beacon.deployed();
  console.log("Beacon deployed at:", beacon.address);

  await writeDeploymentInfo(beacon, "beacon");

  //PieceIssuerNFT deploy
  const PieceIssuerNFT = await ethers.getContractFactory("PieceIssuerNFT", {
    libraries: {
      PetIdentityActions: petIdentityActions.address,
    },
  });
  const pieceIssuerNFT = await upgrades.deployProxy(
    PieceIssuerNFT,
    [beacon.address, ownerIssuer, nameIssuer, symbolIssuer],
    {
      unsafeAllow: ["external-library-linking"],
      initializer: "initialize",
    }
  );

  console.log("PieceIssuerNFT deployed to:", pieceIssuerNFT.address);
  await writeDeploymentInfo(pieceIssuerNFT, "pieceIssuerNFT");
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

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
