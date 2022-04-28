// contracts/Molecule.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Molecule is ERC721URIStorage, ERC1155Holder {
    using SafeMath for uint256;

    uint256 public tokenCounter;
    address public owner;

    mapping(address => mapping(uint256 => uint256)) public elementTransmitters;
    mapping(uint256 => mapping(uint256 => uint256)) public moleculeCompound;

    constructor () public ERC721 ("MOLECULES", "MOL"){
        tokenCounter = 0;
        owner = msg.sender;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC1155Receiver) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    modifier hasMinimalCost(uint256 id, address addr) {
        uint256[18] memory composition = getMoleculeCompound(id);
        uint256[18] memory balances = getElementsBalance(addr);

        for(uint i = 0; i < 18; i++) {
            require(balances[i] >= composition[i], "Not enought elements.");
        }
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Owner only can perform this action.");
        _;
    }

    function getMoleculeCompound(uint256 token_id) public view returns(uint256[18] memory) {
        uint256[18] memory compound;

        for(uint i = 0; i < 18; i++) {
            compound[i] = moleculeCompound[token_id][i];
        }

        return compound;
    }

    function getElementsBalance(address addr) public view returns(uint256[18] memory) {
        uint256[18] memory balance;

        for(uint i = 0; i < 18; i++) {
            balance[i] = elementTransmitters[addr][i];
        }

        return balance;
    }

    function mintMolecule(string memory tokenURI, uint256[18] memory compound) public onlyOwner returns (uint256) {
        uint256 molId = tokenCounter;
        _safeMint(msg.sender, molId);
        _setTokenURI(molId, tokenURI);
        tokenCounter = tokenCounter + 1;

        for(uint i = 0; i < compound.length; i++) {
            if(compound[i] != 0) {
                moleculeCompound[molId][i] = compound[i];
            }
        }

        return molId;
    }

    function requestObtain(
        address account,
        uint256 id)
        public hasMinimalCost(id, account) {

        address operator = msg.sender;
        emit ObtainRequested(operator, account, owner, id);

        uint256[18] memory composition = getMoleculeCompound(id);

        for(uint256 i = 0; i < 18; i++) {
            elementTransmitters[account][i] = elementTransmitters[account][i].sub(composition[i]);
        }

        safeTransferFrom(owner, account, id);
    }

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value, 
        bytes memory data)
        public override returns(bytes4) {
        
        emit ElementReceived(from, id, value);
        elementTransmitters[from][id] = elementTransmitters[from][id].add(value);

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

    event ElementReceived(address sender, uint256 id, uint256 count);
    event ObtainRequested(address operator, address applicant, address owner, uint256 id);
}