const hre = require("hardhat");
const fsPromises = require("fs").promises;

async function main() {
  const [deployer] = await ethers.getSigners();
  const nameIssuer = "PieceIssuerNFT";
  const symbolIssuer = "PINFT";
  const ownerIssuer = "0xd20A336057A940BCae44554B1B5CbC2C716bED5d";
  const service = "0xd20A336057A940BCae44554B1B5CbC2C716bED5d";

  console.log("Deploying contracts with the account:", deployer.address);

  const PieceIssuerNFT = await ethers.getContractFactory("PieceIssuerNFT", {
    libraries: {
      PetIdentityActions: "0x2a108bcf9eA00B14A12816a81Bc8Ea22d1CFf643",
    },
  });
  const pieceIssuerNFT = await upgrades.deployProxy(
    PieceIssuerNFT,
    [
      "0xd79B502aa91856037DE977CeE94a5966D5276dcc",
      ownerIssuer,
      nameIssuer,
      symbolIssuer,
    ],
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

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
