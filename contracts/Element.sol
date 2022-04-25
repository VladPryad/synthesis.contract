// contracts/Element.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Element is ERC1155, ERC1155Holder {

    using SafeMath for uint256;

    uint256 public constant H = 1;
    uint256 public constant Li = 3;
    uint256 public constant Na = 11;
    uint256 public constant O = 8;
    uint256 public constant C = 6;
    uint256 public constant N = 7;
    uint256 public constant Cl = 17;
    uint256 public constant P = 15;
    uint256 public constant S = 16;

    struct ElementCompound {
        uint256 e_count;
        uint256 p_count;
        uint256 n_count;
    }

    mapping(address => mapping(uint256 => uint256)) public particleTransmitters;

    mapping(uint256 => ElementCompound) public elementsComposition;

    constructor() ERC1155("https://synthesis.example/api/item/{id}.json") {

        elementsComposition[H] = ElementCompound(1, 1, 0);
        elementsComposition[Li] = ElementCompound(3, 3, 4);
        elementsComposition[Na] = ElementCompound(11, 11, 12);
        elementsComposition[O] = ElementCompound(8, 8, 8);
        elementsComposition[C] = ElementCompound(6, 6, 6);
        elementsComposition[N] = ElementCompound(7, 7, 7);
        elementsComposition[Cl] = ElementCompound(17, 17, 17);
        elementsComposition[P] = ElementCompound(15, 15, 16);
        elementsComposition[S] = ElementCompound(16, 16, 16);

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

    function getElementCompound(uint256 token_id) public view returns(ElementCompound memory) {

        return elementsComposition[token_id];
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155, ERC1155Receiver) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value, 
        bytes memory data)
        public override returns(bytes4) {
        
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
}