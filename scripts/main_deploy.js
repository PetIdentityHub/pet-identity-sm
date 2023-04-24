const hre = require("hardhat");
const fsPromises = require("fs").promises;

async function main() {
  await hre.run("compile");

  const [deployer] = await ethers.getSigners();
  //PetProfile initial values
  const namePetProfile = "PetProfileNFT";
  const symbolPetProfile = "PPNFT";
  const ownerPetProfile = "0x3fA5eEC0594Fff8D614C0560AcC848D8c300f9B4";
  const servicePetProfile = "0x3fA5eEC0594Fff8D614C0560AcC848D8c300f9B4";

  //PieceIssuer initial values
  const nameIssuer = "PieceIssuerNFT";
  const symbolIssuer = "PINFT";
  const ownerIssuer = "0x3fA5eEC0594Fff8D614C0560AcC848D8c300f9B4";
  const serviceIssuer = "0x3fA5eEC0594Fff8D614C0560AcC848D8c300f9B4";

  //Beacon initial values
  const ownerBeacon = "0x3fA5eEC0594Fff8D614C0560AcC848D8c300f9B4";

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
  await writeDeploymentInfo(petIdentityActions, "petIdentityActions.json");

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
  await writeDeploymentInfo(petProfileNFT, "petProfileNFT.json");

  console.log("Deploying contracts with the account:", deployer.address);

  const PieceNFT = await ethers.getContractFactory("IdentityPiecesNFT");
  const pieceNFTImplementation = await PieceNFT.deploy();
  await pieceNFTImplementation.deployed();
  console.log(
    "PieceNFT implementation deployed at:",
    pieceNFTImplementation.address
  );

  await writeDeploymentInfo(pieceNFTImplementation, "identityPieceNFT.json");

  const Beacon = await hre.ethers.getContractFactory("UpgradeableBeacon");
  const beacon = await Beacon.deploy(
    pieceNFTImplementation.address,
    ownerBeacon
  );
  await beacon.deployed();
  console.log("Beacon deployed at:", beacon.address);

  await writeDeploymentInfo(beacon, "beacon.json");

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
  await writeDeploymentInfo(pieceIssuerNFT, "pieceIssuerNFT.json");
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
  await fsPromises.writeFile(
    "deployment_logs/".concat(
      filename,
      "_",
      new Date().toISOString().slice(0, 10)
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
