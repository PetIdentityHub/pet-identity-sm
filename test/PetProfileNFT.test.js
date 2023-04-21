const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");

describe("PetProfileNFT", function () {
  let owner, service, acc0, acc1, acc2, PetProfileNFT, petProfileNFT;

  beforeEach(async function () {
    [owner, service, acc0, acc1, acc2] = await ethers.getSigners();
    PetProfileNFT = await ethers.getContractFactory("PetProfileNFT");
    petProfileNFT = await upgrades.deployProxy(
      PetProfileNFT,
      [owner.address, service.address, "PetProfileNFT", "PPNFT"],
      { initializer: "initialize" }
    );
    await petProfileNFT.deployed();
  });

  describe("Deployment", function () {
    it("should set the right owner", async function () {
      expect(await petProfileNFT.owner()).to.equal(owner.address);
    });
  });

  describe("Pet Profile created", function () {
    let petProfileId;
    const petProfile = {
      name: "Buddy",
      chipId: "123456789",
      pieces: [],
    };
    const metadataURI = "ipfs://QmW2WQi7j6c7UgJTarActp7tDNikE4B2qXtFCfLPdsgaTQ";

    beforeEach(async function () {
      const tx = await petProfileNFT
        .connect(acc0)
        .createPetProfile(petProfile, metadataURI);
      const receipt = await tx.wait();
      const event = receipt.events.find((e) => e.event === "PetProfileCreated");
      petProfileId = event.args[1].toNumber();
    });
    it("Should create a pet profile with correct ID", async function () {
      expect(petProfileId).to.not.equal(0);
      expect(
        await petProfileNFT.connect(acc0).getChipId(petProfileId)
      ).to.equal(petProfile.chipId);
    });
    it("Should create a pet profile with correct metadata", async function () {
      expect(await petProfileNFT.connect(acc0).tokenURI(petProfileId)).to.equal(
        metadataURI
      );
    });
    it("Should create a pet profile with correct owner acc0", async function () {
      expect(await petProfileNFT.connect(acc0).ownerOf(petProfileId)).to.equal(
        acc0.address
      );
    });
    it("Should create a pet profile with not owner acc1", async function () {
      expect(
        await petProfileNFT.connect(acc1).ownerOf(petProfileId)
      ).to.not.equal(acc1.address);
    });
    it("Should get correct chip id by existing profile id", async function () {
      expect(
        await petProfileNFT.connect(acc0).getChipId(petProfileId)
      ).to.equal(petProfile.chipId);
    });
    it("Should revert get chip id by not existing profile id", async function () {
      await expect(
        petProfileNFT.connect(acc0).getChipId(petProfileId + 1)
      ).to.be.revertedWith("ERC721: invalid token ID");
    });
    it("Should revert update pet profile metadata with wrong owner and good connected service", async function () {
      const newMetadataURI = "ipfs://meta-data-uri";
      await expect(
        petProfileNFT
          .connect(service)
          .updatePetProfileMetadata(petProfileId, acc1.address, newMetadataURI)
      ).to.be.revertedWith("ERC721: caller is not owner nor approved");
    });
    it("Should update pet profile metadata with correct owner and good connected service", async function () {
      const newMetadataURI = "ipfs://meta-data-uri";
      await petProfileNFT
        .connect(service)
        .updatePetProfileMetadata(petProfileId, acc0.address, newMetadataURI);
      expect(await petProfileNFT.connect(acc0).tokenURI(petProfileId)).to.equal(
        newMetadataURI
      );
    });
    it("Should revert get profile id by chip id when chip id is empty", async function () {
      await expect(
        petProfileNFT.connect(acc0).getProfileIdByChipId("")
      ).to.be.revertedWith("EMPTY_CHIP_ID");
    });
    it("Should get profile id by chip id when chip id exist", async function () {
      expect(
        await petProfileNFT
          .connect(acc0)
          .getProfileIdByChipId(petProfile.chipId)
      ).to.equal(petProfileId);
    });
    it("Should revert update chipId when not owner", async function () {
      await expect(
        petProfileNFT.connect(acc1).updateChipId(petProfileId, "123456789")
      ).to.be.revertedWith("ERC721: caller is not owner nor approved");
    });
    it("Should revert update chipId when token not exist", async function () {
      await expect(
        petProfileNFT.connect(acc0).updateChipId(petProfileId + 1, "1234567890")
      ).to.be.revertedWith("ERC721: invalid token ID");
    });
    it("Should revert update chipId when chipId already exist", async function () {
      expect(
        await petProfileNFT
          .connect(acc0)
          .updateChipId(petProfileId, "1234567890")
      ).to.be.revertedWith("CHIP_ID_ALREADY_EXIST");
    });
    it("Should revert update chipId when chipId is empty", async function () {
      await expect(
        petProfileNFT.connect(acc0).updateChipId(petProfileId, "")
      ).to.be.revertedWith("EMPTY_CHIP_ID");
    });
    it("Should update chipId when owner and chipId not empty", async function () {
      await petProfileNFT
        .connect(acc0)
        .updateChipId(petProfileId, "1234567890");
      expect(
        await petProfileNFT.connect(acc0).getChipId(petProfileId)
      ).to.equal("1234567890");
    });
    it("Should revert get profile id when name is empty", async function () {
      await expect(
        petProfileNFT.connect(acc0).getProfileIdByName("")
      ).to.be.revertedWith("EMPTY_PET_NAME");
    });
    it("Should get profile id when name exist", async function () {
      expect(
        await petProfileNFT.connect(acc0).getProfileIdByName(petProfile.name)
      ).to.equal(petProfileId);
    });
  });

  describe("Pet Profile not created", function () {
    it("Should not create a pet profile with empty name", async function () {
      const petProfile = {
        name: "",
        chipId: "123456789",
        pieces: [],
      };
      const metadataURI =
        "ipfs://QmW2WQi7j6c7UgJTarActp7tDNikE4B2qXtFCfLPdsgaTQ";
      await expect(
        petProfileNFT.connect(acc0).createPetProfile(petProfile, metadataURI)
      ).to.be.revertedWith("INVALID_INPUT");
    });
    it("Should not create a pet profile with empty chipId", async function () {
      const petProfile = {
        name: "Dog",
        chipId: "",
        pieces: [],
      };
      const metadataURI =
        "ipfs://QmW2WQi7j6c7UgJTarActp7tDNikE4B2qXtFCfLPdsgaTQ";
      await expect(
        petProfileNFT.connect(acc0).createPetProfile(petProfile, metadataURI)
      ).to.be.revertedWith("INVALID_INPUT");
    });
    it("Should not create a pet profile with empty metadataURI", async function () {
      const petProfile = {
        name: "Dog",
        chipId: "123456789",
        pieces: [],
      };
      const metadataURI = "";
      await expect(
        petProfileNFT.connect(acc0).createPetProfile(petProfile, metadataURI)
      ).to.be.revertedWith("INVALID_INPUT");
    });
    it("Should not create a pet profile with already existing chipId", async function () {
      const petProfile = {
        name: "Dog",
        chipId: "123456789",
        pieces: [],
      };
      const metadataURI =
        "ipfs://QmW2WQi7j6c7UgJTarActp7tDNikE4B2qXtFCfLPdsgaTQ";

      await petProfileNFT
        .connect(acc0)
        .createPetProfile(petProfile, metadataURI);
      await expect(
        petProfileNFT.connect(acc0).createPetProfile(petProfile, metadataURI)
      ).to.be.revertedWith("CHIP_ID_ALREADY_EXISTS");
    });
  });
});

async function createPetProfileAndGetId(petProfile, metadataURI) {
  const tx = await petProfileNFT.createPetProfile(petProfile, metadataURI);
  const receipt = await tx.wait();
  const event = receipt.events.find((e) => e.event === "PetProfileCreated");
  const petProfileId = event.args[1].toNumber();
  return petProfileId;
}
