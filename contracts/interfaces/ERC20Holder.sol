// contracts/interfaces/IERC20Receiver.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20Receiver.sol";

contract ERC20Holder is ERC20Receiver {
    function onERC20Received(
        address,
        uint256,
        uint256
    ) public virtual override returns (bool) {
        return true;
    }
}