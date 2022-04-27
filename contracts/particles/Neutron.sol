// contracts/particles/Neutron.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "../interfaces/IERC20Receiver.sol";

contract Neutron is ERC20 {
    using Address for address;

    uint256 public constant id = 2;

    constructor(uint256 initialSupply) ERC20("Neutron", "NNN") {
        _mint(msg.sender, initialSupply);
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount) internal override {
        _doTransferAcceptanceCheck(from, to, id, amount);
    }

    function _doTransferAcceptanceCheck(
        address from,
        address to,
        uint256 id,
        uint256 amount
    ) private {
        if (to.isContract()) {
            try IERC20Receiver(to).onERC20Received(from, id, amount) returns (bool response) {
                if (!response) {
                    revert("ERC20: ERC20Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC20: transfer to non IERC20Receiver implementer");
            }
        }
    }
}