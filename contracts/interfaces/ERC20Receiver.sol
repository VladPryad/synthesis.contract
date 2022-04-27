// contracts/interfaces/IERC20Receiver.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "./IERC20Receiver.sol";

abstract contract ERC20Receiver is ERC165, IERC20Receiver {
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC20Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
}