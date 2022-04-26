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

        Molecule = await ethers.getContractFactory('Molecule');
        molecule = await Molecule.deploy();

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
    });

    describe("Element minting", () => {

        it('Transfer particles and minting element', async () => {
            let Li_id = 3;

            await particle.connect(addr1).setApprovalForAll(owner.address, true);

            await particle.safeTransferFrom(owner.address, addr1.address, 0, 3, "0x00");
            await particle.safeTransferFrom(owner.address, addr1.address, 1, 3, "0x00");
            await particle.safeTransferFrom(owner.address, addr1.address, 2, 4, "0x00");

            await particle.safeTransferFrom(addr1.address, element.address, 0, 3, "0x00");
            await particle.safeTransferFrom(addr1.address, element.address, 1, 3, "0x00");
            await particle.safeTransferFrom(addr1.address, element.address, 2, 4, "0x00");

            // console.log(`Particles balance@${addr1.address}: `, await element.getParticlesBalance(addr1.address))

            await element.connect(addr1).setApprovalForAll(owner.address, true);

            expect(await element.isApprovedForAll(addr1.address, owner.address)).to.equal(true);

            await element.connect(owner).requestObtain(addr1.address, Li_id, 1, "0x00");

            let balanceLi = await element.balanceOf(addr1.address, Li_id);
            expect(balanceLi).to.equal(BigNumber.from(1))
        })
    });

    describe("Element => Molecule transfer", () => {
        const H_id = 1;
        const O_id = 8;

        beforeEach(async () => {
            await particle.connect(addr1).setApprovalForAll(owner.address, true);

            await particle.safeTransferFrom(owner.address, addr1.address, 0, 2+8, "0x00");
            await particle.safeTransferFrom(owner.address, addr1.address, 1, 2+8, "0x00");
            await particle.safeTransferFrom(owner.address, addr1.address, 2, 0+8, "0x00");

            await particle.safeTransferFrom(addr1.address, element.address, 0, 2+8, "0x00");
            await particle.safeTransferFrom(addr1.address, element.address, 1, 2+8, "0x00");
            await particle.safeTransferFrom(addr1.address, element.address, 2, 0+8, "0x00");

            // console.log(`Particles balance@${addr1.address}: `, await element.getParticlesBalance(addr1.address))

            await element.connect(addr1).setApprovalForAll(owner.address, true);

            expect(await element.isApprovedForAll(addr1.address, owner.address)).to.equal(true);

            await element.connect(owner).requestObtain(addr1.address, H_id, 2, "0x00");
            await element.connect(owner).requestObtain(addr1.address, O_id, 1, "0x00");

            expect(await element.balanceOf(addr1.address, H_id)).to.equal(BigNumber.from(2));
            expect(await element.balanceOf(addr1.address, O_id)).to.equal(BigNumber.from(1));
        })

        it("Minting H2O molecule nft", async () => {
            const waterAtomicCompound = [0,2,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0];

            await molecule.mintMolecule("", waterAtomicCompound);

            let h2ocomp = await molecule.getMoleculeCompound(0);
            h2ocomp = h2ocomp.map(el => el.toNumber())

            expect(h2ocomp).to.eql(waterAtomicCompound);
        });

        describe("Obtaining water nft", () => {
            const waterAtomicCompound = [0,2,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0];

            beforeEach(async () => {
                await molecule.mintMolecule("", waterAtomicCompound);

                let h2ocomp = await molecule.getMoleculeCompound(0);
                h2ocomp = h2ocomp.map(el => el.toNumber())

                expect(h2ocomp).to.eql(waterAtomicCompound);
            })

            it("Transferring elements for molecule", async () => {

                await element.connect(addr1).safeTransferFrom(addr1.address, molecule.address, H_id, 2, "0x00");
                await element.connect(addr1).safeTransferFrom(addr1.address, molecule.address, O_id, 1, "0x00");

                let bal = await molecule.getElementsBalance(addr1.address);
                bal = bal.map(el => el.toNumber())

                expect(bal).to.eql(waterAtomicCompound);
            })
        })

    })
});