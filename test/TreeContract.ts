import { ethers } from "hardhat";
import chai from "chai";
import { TreeContract } from "../typechain-types";
import { ContractFactory, parseEther, Signer } from "ethers";
const { expect } = chai;

describe("Trees", function () {
  let TreesFactory: ContractFactory;
  let trees: TreeContract;
  let owner: Signer;
  let addr1: Signer;
  let addr2: Signer;
  let greenDonationContract: Signer;

  beforeEach(async function () {
    TreesFactory = await ethers.getContractFactory("TreeContract");
    [owner, addr1, addr2, greenDonationContract] = await ethers.getSigners();
    trees = (await TreesFactory.deploy(
      "https://example.com/api/token/"
    )) as TreeContract;
    await trees.waitForDeployment();
  });

  describe("Deployment", function () {
    it("Should set the right owner", async function () {
      expect(await trees.owner()).to.equal(await owner.getAddress());
    });

    it("Should set the right base URI", async function () {
      expect(await trees._baseTokenURI()).to.equal(
        "https://example.com/api/token/"
      );
    });
  });

  describe("Minting", function () {
    it("Should allow owner to mint tokens", async function () {
      await trees.connect(owner).mint(5, { value: parseEther("0") });
      expect(await trees.balanceOf(await owner.getAddress())).to.equal(5);
    });

    it("Should not allow minting more than the maximum limit", async function () {
      await expect(
        trees.connect(owner).mint(11, { value: parseEther("0") })
      ).to.be.revertedWith("Exceed max mintable amount");
    });
  });

  describe("Cost Management", function () {
    it("Should allow owner to change the minting cost", async function () {
      await trees.connect(owner).setCost(parseEther("0.01"));
      expect(await trees.cost()).to.equal(parseEther("0.01"));
    });

    it("Should not allow non-owners to change the minting cost", async function () {
      await expect(trees.connect(addr1).setCost(parseEther("0.01"))).to.be
        .reverted;
    });
  });

  describe("Watering Trees", function () {
    beforeEach(async function () {
      await trees.connect(owner).mint(1, { value: parseEther("0") });
    });

    it("Should allow greenDonationContract to water a tree", async function () {
      await trees.setGreenDonationContract(
        await greenDonationContract.getAddress()
      );
      await trees.connect(greenDonationContract).waterTree(1);
      const tree = await trees.trees(1);
      expect(tree.level).to.equal(2);
    });

    it("Should not allow others to water a tree", async function () {
      await expect(trees.connect(addr1).waterTree(1)).to.be.revertedWith(
        "Only green donation contract can call this function"
      );
    });
  });
});
