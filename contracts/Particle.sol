// contracts/Elementary.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract Particle is ERC1155 {
    uint256 public constant ELECTRON = 0;
    uint256 public constant PROTON = 1;
    uint256 public constant NEUTRON = 2;

    constructor() ERC1155("https://synthesis.example/api/item/{id}.json") {
        _mint(msg.sender, ELECTRON, 84*10**27, "");
        _mint(msg.sender, PROTON, 84*10**27, "");
        _mint(msg.sender, NEUTRON, 86*10**27, "");
    }
}