const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("OnChain Nfts", function () {
	let OnChainNft, nftContract, owner, addr1, addr2, addr3, addrs;
	beforeEach(async function () {
		OnChainNft = await ethers.getContractFactory("OnchainNft");
		[owner, addr1, addr2, addr3, ...addrs] = await ethers.getSigners();
		nftContract = await OnChainNft.deploy();
	});

	describe("Deployment", function () {
		it("Should set the right owner", async function () {
			expect(await nftContract.owner()).to.equal(owner.address);
		});
	});
});
