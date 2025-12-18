// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title AntiMEV
 * @author The-Trapper (Red Team)
 * @notice TRAP EXPLANATION:
 * This contract detects common simulation and MEV bot behaviors.
 *
 * THE BAIT:
 * - A function `flashArb` that looks like a highly profitable arbitrage opportunity.
 * - It checks a visible "profit" condition that seems always true.
 *
 * THE TRAP:
 * - It checks `tx.gasprice` or block properties to detect if it's being simulated
 *   or if it's being included in a bundle with high gas price (frontrunning).
 * - If detected, it performs a "Silent Fail" or a "Gas Bomb".
 * - NOTE: `cobinbase` check is a classic way to detect if block builder is the destination,
 *   but here we'll use a `gasleft()` check or similar heuristic.
 */

contract AntiMEV {
    uint256 public constant SECRET_THRESHOLD = 50 gwei;

    // Bait event
    event ArbitrageOpportunity(uint256 expectedProfit);

    // Trap event
    event Gotcha(address indexed bot);

    // Allow deposits so there is ETH to steal
    receive() external payable {}

    /**
     * @notice Looks like a free money button.
     * Attacker calls this thinking they can drain the contract.
     */
    function claimProfit() external {
        // OPTIONAL: Bait logic - require some condition that's strictly true
        require(address(this).balance > 0, "No funds");

        // --- THE TRAP ZONE ---
        
        // 1. Simulation Detection via env modifications? 
        // Hard to do deterministically, but we can check specific MEV bot patterns.
        
        // 2. Gas Price Check (Accessing tx.gasprice)
        // MEV bots often bid high gas to frontrun.
        // If gas price is suspiciously high, we trap.
        if (tx.gasprice > SECRET_THRESHOLD) {
            _activateTrap();
        }

        // 3. Origin check (bots often use smart contracts as initiators, but `tx.origin` might differ)
        // If msg.sender is a contract (attacker via proxy) but we want to punish them.
        if (msg.sender != tx.origin) {
            // Often bots operate through proxy contracts.
            // We can add a hidden check that penalizes contract callers specifically in a subtle context.
        }

        // If we reach here without trapping, we pretend to fail a logic check
        // so real users (or low gas attempts) just get a revert, shielding the funds.
        revert("Conditions changed");
    }

    function _activateTrap() private {
        // Emit event for our logging
        emit Gotcha(msg.sender);

        // GAS BOMB: Loop until gas runs out
        // The attacker simulates, sees success (maybe we trick simulation by checking block.number),
        // but in real execution we burn.
        // To trick simulation: checking `block.coinbase` can sometimes differentiate if the simulator 
        // hasn't mocked it correctly, OR checking if we are in a flashbots bundle (harder on-chain).
        
        // Simple trap: just brick the call
        uint256 i = 0;
        while(gasleft() > 1000) {
            i++;
        }
    }
}
