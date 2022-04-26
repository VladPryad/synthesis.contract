// contracts/Element.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Element is ERC1155, ERC1155Holder {

    using SafeMath for uint256;

    address public owner;

    uint256 public constant H = 1;
    uint256 public constant Li = 3;
    uint256 public constant Na = 11;
    uint256 public constant O = 8;
    uint256 public constant C = 6;
    uint256 public constant N = 7;
    uint256 public constant Cl = 17;
    uint256 public constant P = 15;
    uint256 public constant S = 16;

    enum Particle { ELECTRON, PROTON, NEUTRON }

    mapping(uint256 => mapping(uint256 => uint256)) public elementsCompound; 
    mapping(address => mapping(uint256 => uint256)) public particleTransmitters;

    constructor() ERC1155("https://synthesis.example/api/item/{id}.json") {

        owner = msg.sender;

        elementsCompound[H][uint256(Particle.ELECTRON)] = 1;
        elementsCompound[H][uint256(Particle.PROTON)] = 1;
        elementsCompound[H][uint256(Particle.NEUTRON)] = 0;

        elementsCompound[Li][uint256(Particle.ELECTRON)] = 3;
        elementsCompound[Li][uint256(Particle.PROTON)] = 3;
        elementsCompound[Li][uint256(Particle.NEUTRON)] = 4;

        elementsCompound[Na][uint256(Particle.ELECTRON)] = 11;
        elementsCompound[Na][uint256(Particle.PROTON)] = 11;
        elementsCompound[Na][uint256(Particle.NEUTRON)] = 12;

        elementsCompound[O][uint256(Particle.ELECTRON)] = 8;
        elementsCompound[O][uint256(Particle.PROTON)] = 8;
        elementsCompound[O][uint256(Particle.NEUTRON)] = 8;

        elementsCompound[C][uint256(Particle.ELECTRON)] = 6;
        elementsCompound[C][uint256(Particle.PROTON)] = 6;
        elementsCompound[C][uint256(Particle.NEUTRON)] = 6;

        elementsCompound[N][uint256(Particle.ELECTRON)] = 7;
        elementsCompound[N][uint256(Particle.PROTON)] = 7;
        elementsCompound[N][uint256(Particle.NEUTRON)] = 7;

        elementsCompound[Cl][uint256(Particle.ELECTRON)] = 17;
        elementsCompound[Cl][uint256(Particle.PROTON)] = 17;
        elementsCompound[Cl][uint256(Particle.NEUTRON)] = 17;

        elementsCompound[P][uint256(Particle.ELECTRON)] = 15;
        elementsCompound[P][uint256(Particle.PROTON)] = 15;
        elementsCompound[P][uint256(Particle.NEUTRON)] = 16;

        elementsCompound[S][uint256(Particle.ELECTRON)] = 16;
        elementsCompound[S][uint256(Particle.PROTON)] = 16;
        elementsCompound[S][uint256(Particle.NEUTRON)] = 16;

        _mint(msg.sender, H, 10**27, "");
        _mint(msg.sender, Li, 10**27, "");
        _mint(msg.sender, Na, 10**27, "");
        _mint(msg.sender, O, 10**27, "");
        _mint(msg.sender, C, 10**27, "");
        _mint(msg.sender, N, 10**27, "");
        _mint(msg.sender, Cl, 10**27, "");
        _mint(msg.sender, P, 10**27, "");
        _mint(msg.sender, S, 10**27, "");
    }

    function getElementCompound(uint256 token_id) public view returns(uint256[3] memory) {

        return [
            elementsCompound[token_id][uint256(Particle.ELECTRON)],
            elementsCompound[token_id][uint256(Particle.PROTON)],
            elementsCompound[token_id][uint256(Particle.NEUTRON)]
        ];
    }
    
    function getParticlesBalance(address addr) public view returns(uint256[3] memory) {

        return [
            particleTransmitters[addr][uint256(Particle.ELECTRON)],
            particleTransmitters[addr][uint256(Particle.PROTON)],
            particleTransmitters[addr][uint256(Particle.NEUTRON)]
        ];
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155, ERC1155Receiver) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    modifier hasMinimalCost(uint256 id, uint256 count, address addr) {
        uint256[3] memory composition = getElementCompound(id);
        uint256[3] memory balances = getParticlesBalance(addr);

        require(balances[uint256(Particle.ELECTRON)] >= composition[uint256(Particle.ELECTRON)].mul(count), "Not enought electrons.");
        require(balances[uint256(Particle.PROTON)] >= composition[uint256(Particle.PROTON)].mul(count), "Not enought neutrons.");
        require(balances[uint256(Particle.NEUTRON)] >= composition[uint256(Particle.NEUTRON)].mul(count), "Not enought protons.");
        _;
    }

    function requestObtain(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data) public hasMinimalCost(id, amount, account) {

        address operator = msg.sender;
        emit ObtainRequested(operator, account, owner, id, amount);

        uint256[3] memory composition = getElementCompound(id);

        particleTransmitters[account][uint256(Particle.ELECTRON)] = particleTransmitters[account][uint256(Particle.ELECTRON)].sub(composition[uint256(Particle.ELECTRON)]);
        particleTransmitters[account][uint256(Particle.PROTON)] = particleTransmitters[account][uint256(Particle.PROTON)].sub(composition[uint256(Particle.PROTON)]);
        particleTransmitters[account][uint256(Particle.NEUTRON)] = particleTransmitters[account][uint256(Particle.NEUTRON)].sub(composition[uint256(Particle.NEUTRON)]);

        safeTransferFrom(owner, account, id, amount, data);
    }

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value, 
        bytes memory data)
        public override returns(bytes4) {
        
        emit ParticleReceived(from, id, value);
        particleTransmitters[from][id] = particleTransmitters[from][id].add(value);

        return bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"));
    }

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] memory ids,
        uint256[] memory values,
        bytes memory data)
        public override returns(bytes4) {

        return bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"));
    }

    event ParticleReceived(address sender, uint256 id, uint256 count);
    event ObtainRequested(address operator, address applicant, address owner, uint256 id, uint256 count);
}