const { expect } = require('chai');
const { BigNumber } = require('ethers');
const { ethers } = require('hardhat');

describe('Element & Particle contract', () => {

    let owner, addr1, addr2;
    let Element, element;
    let Molecule, molecule;

    let electron, proton, neutron;

    beforeEach(async () => {

        Particle = await ethers.getContractFactory('Particle');

        electron = await Particle.deploy("84000000000000000000000000000", "EEE", "Electron", 0);
        proton = await Particle.deploy("84000000000000000000000000000", "PPP", "Proton", 1);
        neutron = await Particle.deploy("86000000000000000000000000000", "NNN", "Neutron", 2);

        Element = await ethers.getContractFactory('Element');
        element = await Element.deploy();

        Molecule = await ethers.getContractFactory('Molecule');
        molecule = await Molecule.deploy();

        [owner, addr1, addr2, _] = await ethers.getSigners();
    })

    describe('Deployment Particles', () => {
        it('Particles owner', async () => {
            expect(await electron.balanceOf(owner.address)).to.equal(BigNumber.from("84000000000000000000000000000"))
            expect(await proton.balanceOf(owner.address)).to.equal(BigNumber.from("84000000000000000000000000000"))
            expect(await neutron.balanceOf(owner.address)).to.equal(BigNumber.from("86000000000000000000000000000"))
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

    describe("Particles => Element transfer", () => {

        it('Transfer electrons to element contract', async () => {
            let token_id = 0;
            let token_count = 3;

            let receipt = await electron.transfer(element.address, token_count);

            let balanceElec = await electron.balanceOf(element.address);
            let balanceElem = await element.getParticlesBalance(owner.address);
            balanceElem = balanceElem.map(el => el.toNumber())

            expect(balanceElec).to.equal(BigNumber.from(3))
            expect(balanceElem).to.eql([3,0,0])
        })
    });

    describe("Element minting", () => {

        it('Transfer particles and minting element', async () => {
            let Li_id = 3;

            await electron.connect(addr1).approve(owner.address, BigNumber.from("0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"));
            await proton.connect(addr1).approve(owner.address, BigNumber.from("0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"));
            await neutron.connect(addr1).approve(owner.address, BigNumber.from("0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"));

            await electron.transfer(addr1.address, 3);
            await proton.transfer(addr1.address, 3);
            await neutron.transfer( addr1.address, 4);

            await electron.connect(addr1).transfer(element.address, 3);
            await proton.connect(addr1).transfer(element.address, 3);
            await neutron.connect(addr1).transfer(element.address, 4);

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

            await electron.connect(addr1).approve(owner.address, BigNumber.from("0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"));
            await proton.connect(addr1).approve(owner.address, BigNumber.from("0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"));
            await neutron.connect(addr1).approve(owner.address, BigNumber.from("0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"));

            await electron.transfer(addr1.address, 10);
            await proton.transfer(addr1.address, 10);
            await neutron.transfer( addr1.address, 8);

            await electron.connect(addr1).transfer(element.address, 10);
            await proton.connect(addr1).transfer(element.address, 10);
            await neutron.connect(addr1).transfer(element.address, 8);

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
                expect(await molecule.ownerOf(0)).to.equal(owner.address);
            })

            it("Transferring elements for molecule", async () => {

                await element.connect(addr1).safeTransferFrom(addr1.address, molecule.address, H_id, 2, "0x00");
                await element.connect(addr1).safeTransferFrom(addr1.address, molecule.address, O_id, 1, "0x00");

                let bal = await molecule.getElementsBalance(addr1.address);
                bal = bal.map(el => el.toNumber())

                expect(bal).to.eql(waterAtomicCompound);
            })

            it("Obtaining water", async () => {

                await element.connect(addr1).safeTransferFrom(addr1.address, molecule.address, H_id, 2, "0x00");
                await element.connect(addr1).safeTransferFrom(addr1.address, molecule.address, O_id, 1, "0x00");

                let bal = await molecule.getElementsBalance(addr1.address);
                bal = bal.map(el => el.toNumber())

                expect(bal).to.eql(waterAtomicCompound);

                await molecule.approve(addr1.address, 0);

                expect(await molecule.getApproved(0)).to.equal(addr1.address);

                await molecule.connect(owner).requestObtain(addr1.address, 0);

                expect(await molecule.ownerOf(0)).to.equal(addr1.address);

                bal = await molecule.getElementsBalance(addr1.address);
                bal = bal.map(el => el.toNumber())

                expect(bal).to.eql([0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]);
            })
        })

    })
});