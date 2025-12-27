# 🗺️ Project Roadmap: The Gamification of Traps

This document outlines the future direction of **The Trapper**, moving from static example contracts to interactive, gamified on-chain experiences.

## 1. 🩸 The Labyrinth (CTF / Challenge Mode)
A progressive capture-the-flag contract where users must bypass multiple layers of security defenses in a single transaction.

*   **Concept**: "The Dark Forest" survival game.
*   **Mechanics**:
    *   **Gate 1 (The Mirror)**: Checks `extcodesize` and `tx.origin` to filter specific callers.
    *   **Gate 2 (The Riddle)**: Requires cracking "private" on-chain variables (reading storage slots).
    *   **Gate 3 (The Greedy)**: A fake reentrancy vulnerability. If the attacker tries to re-enter, the trap triggers a `SelfDestruct` or infinite loop to consume all gas.
*   **Goal**: Retrieve the locked ETH bounty without getting trapped.

## 2. 💣 Hot Potato (Cursed Token)
A viral, self-destructing ERC20 token experiment designed to simulate high-pressure trading environments.

*   **Concept**: A digital curse or "Tag" game.
*   **Mechanics**:
    *   **Auto-Decay**: Holder balances decrease every block (Negative Rebase).
    *   **Contagion**: The only way to stop decay is to transfer the token to a new address.
    *   **The Trap**: Attempting to sell to a known DEX pair (Uniswap/Sushi) triggers an "Anti-Dump" mechanism (e.g., freezing the assets or reverting with high gas consumption).

## 3. 🕸️ Spider & Fly (MEV Honeycomb)
A dynamic trap specifically designed to detect, capture, and visualize MEV (Maximal Extractable Value) bots in action.

*   **Concept**: An active hunting ground for arbitrage bots.
*   **Mechanics**:
    *   **Bait**: The contract periodically exposes calculated, profitable arbitrage opportunities.
    *   **Trigger**: Detects Flashbots bundles, high gas price manipulation, or specific miner payments.
    *   **Capture**: Instead of yielding profit, the contract consumes the attacker's gas and/or mints a "Caught Fly" NFT to the attacking address as a badge of shame (or honor).
