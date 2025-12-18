// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title ReentrancyBait
 * @author The-Trapper (Red Team)
 * @notice TRAP EXPLANATION:
 * This contract exposes a classic reentrancy vulnerability.
 *
 * THE BAIT:
 * - A `withdraw` function that sends ETH *before* updating the balance.
 * - This violates Checks-Effects-Interactions pattern.
 *
 * THE TRAP:
 * - We use a secondary variable `_locked` or `gas` check that acts as a mutex
 *   BUT it's hidden or implemented in a way that allows the FIRST reentry but fails deeply
 *   nested ones, or traps the funds by updating a different state on reentry.
 * - Actually, a fun trap is: The reentrancy allows you to "double spend" but the
 *   `transfer` uses a limited amount of gas that is enough for a wallet receive
 *   but NOT enough for the complex fallback logic of the attacker.
 * - OR: We update a shadow balance in the reentrancy that results in 0 payout globally.
 */

contract ReentrancyBait {
    mapping(address => uint256) public balances;
    bool private _shadowLock;

    constructor() payable {}

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    /**
     * @notice The Vulnerable Function.
     * Attacker sees: call(value) BEFORE balances[msg.sender] = 0.
     */
    function withdraw() external {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "No balance");

        // TRAP SETUP:
        // We set a flag that is NOT checked here, but checked deep in the logic or
        // we use a subtle gas restriction.
        // Let's use a hidden flag that corrupts the state if re-entered.
        
        bool alreadyEntered = _shadowLock;
        _shadowLock = true; // Set lock for the re-entrant call

        // THE VULNERABILITY (BAIT)
        // We send ETH. Attacker's fallback triggers here.
        // They call withdraw() again.
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");

        // THE TRAP LOGIC (Post-execution or during re-execution)
        // If they re-entered, `_shadowLock` was true during the second call.
        // But wait, standard reentrancy protection usually reverts.
        // We want to TRAP them (waste gas or make them think they succeeded until the end).
        
        // The real trap:
        // In the re-entrant call, `balances` is NOT yet 0. So they get funds twice?
        // No, because we can revert ONLY if reentrancy happened, wasting their gas for the whole tx.
        // Or better: The second transfer implies `balances` is still high, but we caught them.
        
        if (alreadyEntered) {
             // If we are here, it means we are in the re-entrant frame or unwinding it.
             // Actually, if they re-enter, the inner withdraw() runs.
             // We can't easily detect "inner" vs "outer" without storage.
             // But `_shadowLock` does that.
             
             // If they successfully re-entered, the inner call returned `success`.
             // We can punish them here.
        }

        balances[msg.sender] = 0;
        _shadowLock = false;
    }
    
    // Better Trap Implementation for Reentrancy:
    // The "View" of the contract looks correct for reentrancy.
    // However, the `call` restricts gas subtly, or we have a `gasleft()` check that fails
    // complex attacker fallbacks.
    
    // Let's stick to the prompt's idea: "Hidden state change".
    // We'll actually use the reentrancy to clear their balance in a way they don't expect.
}
