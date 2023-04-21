const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");

describe("PieceIssuerNFT", function () {
  let owner, acc0, acc1, acc2;
  let PieceIssuerNFT, PetIdentityActions;
  let pieceIssuerNFT, petIdentityActions;
  const zeroAddress = "0x0000000000000000000000000000000000000000";

  beforeEach(async function () {
    [owner, acc0, acc1, acc2] = await ethers.getSigners();
    PetIdentityActions = await ethers.getContractFactory("PetIdentityActions");
    petIdentityActions = await PetIdentityActions.deploy();

    PieceIssuerNFT = await ethers.getContractFactory("PieceIssuerNFT", {
      libraries: {
        PetIdentityActions: petIdentityActions.address,
      },
    });

    pieceIssuerNFT = await upgrades.deployProxy(
      PieceIssuerNFT,
      [owner.address, "PieceIssuerNFT", "PINFT"],
      { initializer: "initialize" }
    );
    await pieceIssuerNFT.deployed();
  });

  describe("Deployment", function () {
    it("should set the right owner", async function () {
      expect(await pieceIssuerNFT.owner()).to.equal(owner.address);
    });
  });

  describe("Piece Issuer application", function () {
    describe("Operator actions", function () {
      it("Should not add operator by not owner", async function () {
        await expect(
          pieceIssuerNFT.connect(acc0).addOperator(acc0.address)
        ).to.be.revertedWith("Ownable: caller is not the owner");
      });
      it("Should not add operator with empty operator address", async function () {
        const data = {
          name: "Test operator",
          string: "Country",
          metadataURI: "ipfs://QmW2WQi7j6c7UgJTarActp7tDNikE4B2qXtFCfLPdsgaTQ",
        };
        await expect(
          pieceIssuerNFT.connect(owner).addOperator(zeroAddress, data)
        ).to.be.revertedWith("INVALID_ADDR");
      });
      it("Should not add operator with empty operator name/country/metadataUri", async function () {
        await expect(
          pieceIssuerNFT.connect(owner).addOperator(acc0.address, {
            name: "",
            string: "Country",
            metadataURI:
              "ipfs://QmW2WQi7j6c7UgJTarActp7tDNikE4B2qXtFCfLPdsgaTQ",
          })
        ).to.be.revertedWith("EMPTY_NAME");
        await expect(
          pieceIssuerNFT.connect(owner).addOperator(acc0.address, {
            name: "Test operator",
            string: "",
            metadataURI:
              "ipfs://QmW2WQi7j6c7UgJTarActp7tDNikE4B2qXtFCfLPdsgaTQ",
          })
        ).to.be.revertedWith("EMPTY_COUNTRY");
        await expect(
          pieceIssuerNFT.connect(owner).addOperator(acc0.address, {
            name: "Test operator",
            string: "Country",
            metadataURI: "",
          })
        ).to.be.revertedWith("EMPTY_METADATA_URI");
      });
      it("Should add operator as owner", async function () {
        const data = {
          name: "Test operator",
          string: "Country",
          metadataURI: "ipfs://QmW2WQi7j6c7UgJTarActp7tDNikE4B2qXtFCfLPdsgaTQ",
        };
        await pieceIssuerNFT.connect(owner).addOperator(acc0.address, data);
        expect(await pieceIssuerNFT.getOperator(acc0.address)).to.equal(data);
      });
    });
    describe("Apply as issuer", function () {
      it("Should not allow apply as issuer if already applied", async function () {
        const data = {
          name: "Test Issuer",
          address: acc1.address,
          metadataURI: "ipfs://QmW2WQi7j6c7UgJTarActp7tDNikE4B2qXtFCfLPdsgaTQ",
        };
        await pieceIssuerNFT
          .connect(acc0)
          .applyAsIssuer(acc0, applicationIssuerData);
        await expect(
          pieceIssuerNFT
            .connect(acc0)
            .applyAsIssuer(acc0, applicationIssuerData)
        ).to.be.revertedWith("PieceIssuerNFT: Already applied");
      });
      it("Should not allow apply as issuer if already issuer", async function () {});
      it("Should now allow apply as operator does not exists", async function () {});
      it("Should allow apply as issuer", async function () {});
    });
    it("Should allow accept issuer application when operator", async function () {});
    it("Should not allow accept issuer application when not operator", async function () {});
    it("Should not allow accept issuer application when not applied", async function () {});
  });
});
