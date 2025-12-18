// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title StorageGhost
 * @author The-Trapper (Red Team)
 * @notice TRAP EXPLANATION:
 * This contract appears to be a standard Proxy/Implementation pattern where
 * the owner can update the implementation.
 *
 * THE BAIT:
 * - A `delegatecall` to an implementation address that seems to allow overwriting the `owner`.
 * - The attacker sees `owner` at slot 0 and `implementation` at slot 1 in the main contract.
 * - The attacker provides a malicious implementation that writes their address to slot 0.
 *
 * THE TRAP:
 * - We use unstructured storage or a subtle inline assembly shift.
 * - In this specific example, the `owner` is NOT at slot 0 despite the declaration order
 *   suggesting it might be alignable.
 * - Actually, we define a different storage layout or use a collision that writes to a
 *   "trap" slot which locks the contract or burns gas, while the real processing happens elsewhere.
 *
 *   For this simple v1:
 *   The `owner` variable is actually shadowed or the layout is messed up by inheritance
 *   or we use EIP-1967 style slots but mislead the attacker about which one is active.
 *
 *   Let's make it simpler but effective:
 *   The "Bait" contract uses `delegatecall` to `lib`. `lib` has `owner` at slot 0.
 *   The "Ghost" contract has a hidden variable at slot 0 that triggers a LOCK when modified.
 */

contract StorageGhost {
    // Hidden trap slot at slot 0.
    // If this value becomes non-zero (which it will if attacker tries to write owner address here),
    // the contract bricks itself.
    uint256 private trapSlot; 

    // Real owner is stored at a random slot defined by a constant.
    bytes32 internal constant _OWNER_SLOT = keccak256("storage.ghost.owner");

    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(msg.sender == _getOwner(), "Not owner");
        _;
    }

    constructor() {
        _setOwner(msg.sender);
    }

    function _getOwner() internal view returns (address owner) {
        bytes32 slot = _OWNER_SLOT;
        assembly {
            owner := sload(slot)
        }
    }

    function _setOwner(address newOwner) internal {
        bytes32 slot = _OWNER_SLOT;
        assembly {
            sstore(slot, newOwner)
        }
        emit OwnershipTransferred(_getOwner(), newOwner);
    }

    // THE BAIT: This function allows executing arbitrary logic via delegatecall.
    // An attacker thinks they can call a function in `target` that does `owner = msg.sender`.
    // Since `trapSlot` is at slot 0, `owner` in the naive implementation would map to slot 0.
    // Writing an address (non-zero) to slot 0 triggers the trap.
    function execute(address target, bytes calldata data) external payable {
        // Trap check: If slot 0 is tampered with, REVERT forever or CONSUME GAS.
        // Initially 0.
        if (trapSlot != 0) {
            // TRAP TRIGGERED: Infinite loop to consume all gas
            assembly {
                invalid()
            }
        }

        (bool success, ) = target.delegatecall(data);
        require(success, "Execution failed");

        // Post-execution trap check
        if (trapSlot != 0) {
            // If the delegatecall modified slot 0 (thinking it was owner), we revert/burn.
             assembly {
                // Return a misleading error or just burn
                revert(0, 0)
            }
        }
    }

    // Helper for legitimate owner to withdraw (proving it's a honeypot, not a burn address)
    function withdraw() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
    
    // Fallback to receive funds
    receive() external payable {}
}
