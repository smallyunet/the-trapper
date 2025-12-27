# THE TRAPPER 🪤

> **STATUS:** 🔴 DANGER // EXPERIMENTAL // DO NOT USE IN PRODUCTION

**The-Trapper** is a collection of **EVM Honeypots** designed for educational purposes and "Defense against the Dark Arts". These smart contracts appear superficially vulnerable to standard exploits (ownership takeover, MEV extraction, reentrancy) but contain hidden mechanisms to trap sophisticated attackers.

## ⚠️ DISCLAIMER

**THIS REPOSITORY IS FOR EDUCATIONAL AND RESEARCH PURPOSES ONLY.**
- The code contained herein is intentionally malicious towards attackers.
- **DO NOT** deploy these contracts to trap innocent users.
- **DO NOT** use this code to steal funds from legitimate participants.
- The authors accept no responsibility for funds lost, locked, or burnt using these patterns.

---

## 📂 The Arsenal

### 1. StorageGhost (`src/traps/StorageGhost.sol`)
**The Bait:**
A classic `delegatecall` vulnerability. The contract allows users to execute arbitrary logic via a delegate call, seemingly allowing an attacker to overwrite the `owner` variable (often assumed to be at Slot 0) by passing a malicious implementation.

**The Trap:**
Uses **Storage Layout Misalignment**. The contract defines a hidden `trapSlot` at Slot 0. The real `owner` is stored at a randomized or unstructured slot (using inline assembly).
- **Outcome:** When the attacker tries to write their address to Slot 0 (thinking it's `owner`), they unknowingly write to `trapSlot`.
- **Punishment:** The contract detects `trapSlot != 0` and enters an infinite loop (consuming all gas) or permanently bricks the contract.

### 2. AntiMEV (`src/traps/AntiMEV.sol`)
**The Bait:**
An exposed method `claimProfit()` that looks like a guaranteed arbitrage opportunity or free mint.

**The Trap:**
Detects simulation execution environments and aggressive MEV behaviors.
- **Mechanism:** Checks `tx.gasprice`, `gasleft()`, and subtle block properties.
- **Punishment:** If extensive gas or simulation patterns are detected, it performs a "Silent Fail" or a "Gas Bomb" (checking conditions that are true only during real execution vs simulation).

### 3. ReentrancyBait (`src/traps/ReentrancyBait.sol`)
**The Bait:**
Violates the specific Checks-Effects-Interactions pattern, sending ETH before updating balances.

**The Trap:**
A hidden reentrancy guard or state corruption trigger.
- **Mechanism:** Uses a shadow variable that is toggled during the call.
- **Punishment:** Standard reentrancy attacks will succeed in the re-entrant call (opcode level) but fail the overall transaction due to a hidden post-execution check, wasting the attacker's gas for the complex attack transaction.

### 4. FlashLoanTrap (`src/traps/FlashLoanTrap.sol`)
**The Bait:**
A flash loan provider with seemingly exploitable callback structure. Attacker thinks they can borrow funds, use them profitably, and not repay.

**The Trap:**
Detects flash loan attack patterns via balance snapshots and interaction tracking.
- **Mechanism:** Tracks same-block repeated interactions, checks if caller/target are contracts, verifies repayment.
- **Punishment:** If flash loan not repaid by a contract caller, triggers `invalid()` opcode to burn all remaining gas.

### 5. HoneypotToken (`src/traps/HoneypotToken.sol`)
**The Bait:**
A standard ERC20 token that seems tradable. The owner mints tokens and makes it look like a new gem.

**The Trap:**
Contains a hidden sell restriction mechanism.
- **Mechanism:** The `_beforeTokenTransfer` hook allows minting and receiving tokens but reverts on any outgoing transfer from a non-owner address.
- **Outcome:** Victims can buy the token (receiving it from a DEX pair) but cannot sell it back.
- **Punishment:** Funds used to buy the token are effectively locked as they cannot be swapped back.

---

## 🛠 Usage

This project uses [Foundry](https://getfoundry.sh).

### Build

### Build
Using Makefile:
```shell
$ make build
```
Or directly:
```shell
$ forge build
```

### Test

Simulate the exploits (and verify the traps trigger):

Using Makefile:
```shell
$ make test
```
Or directly:
```shell
$ forge test
```

### Deploy (Local Anvil)

```shell
$ anvil
$ forge script script/DeployTraps.s.sol --rpc-url localhost
```

---

*Stay safe, stay paranoid.*
# the-trapper
