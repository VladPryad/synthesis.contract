// contracts/interfaces/IERC20Receiver.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface IERC20Receiver is IERC165 {
    function onERC20Received(
        address from,
        uint256 id,
        uint256 value
    ) external returns(bool);
}
