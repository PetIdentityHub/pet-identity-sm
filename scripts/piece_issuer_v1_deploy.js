const hre = require("hardhat");
const fs = require("fs");

async function main() {
  const [deployer] = await ethers.getSigners();
  const name = "PieceIssuerNFT";
  const symbol = "PINFT";
  const owner = "0xd20A336057A940BCae44554B1B5CbC2C716bED5d";
  const service = "0xd20A336057A940BCae44554B1B5CbC2C716bED5d";

  console.log("Deploying contracts with the account:", deployer.address);

  const PieceIssuerNFT = await ethers.getContractFactory("PieceIssuerNFT");
  const pieceIssuerNFT = await upgrades.deployProxy(
    PieceIssuerNFT,
    [owner, service, name, symbol],
    {
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
  await fs.writeFile(filename, content, { encoding: "utf-8" });
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
