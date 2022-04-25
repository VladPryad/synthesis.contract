const { expect } = require('chai');
const { BigNumber } = require('ethers');
const { ethers } = require('hardhat');

describe('Element & Particle contract', () => {

    let owner, addr1, addr2;
    let Element, element;
    let Particle, particle;

    beforeEach(async () => {
        Element = await ethers.getContractFactory('Element');
        element = await Element.deploy();

        Particle = await ethers.getContractFactory('Particle');
        particle = await Particle.deploy();

        [owner, addr1, addr2, _] = await ethers.getSigners();
    })

    describe('Deployment Particle', () => {
        it('Particle owner', async () => {
            const count = await particle.balanceOf(owner.address, 0);
            expect(count).to.equal(BigNumber.from("84000000000000000000000000000"))
        })
    })

    describe('Deployment Element', () => {
        it('Element owner', async () => {
            const count = await element.balanceOf(owner.address, 1);
            expect(count).to.equal(BigNumber.from("1000000000000000000000000000"))
        })

        it('Element compound view', async () => {
            let token_id = 1;
            const compound = await element.getElementCompound(token_id);
            // console.log("Hydrogen compound: ", compound);
        })
    })

    describe("Particle => Element transfer", () => {

        it('Transfer electrons to element contract', async () => {
            let token_id = 0;
            let token_count = 3;

            let receipt = await particle.safeTransferFrom(owner.address, element.address, token_id, token_count, "0x00");

            console.log('Checking electrons received');
            let balanceE = await particle.balanceOf(element.address, token_id);
            expect(balanceE).to.equal(BigNumber.from(3))
        })
    })
});