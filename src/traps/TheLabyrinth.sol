// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title The Labyrinth
 * @notice A progressive CTF challenge.
 * @dev The goal is to successfully call `solve` and retrieve the bounty.
 * There are 3 gates to pass.
 */
contract TheLabyrinth {
    bytes32 private secret;
    bool private locked;
    
    event ChallengeSolved(address winner, uint256 bounty);
    event TrapTriggered(address victim, string trapName);

    constructor() payable {
        // In a real scenario, this would be set to something harder to guess or purely random
        // For this education example, we mock it.
        secret = keccak256(abi.encodePacked("YouShallNotPass", block.timestamp));
    }

    /**
     * @notice Attempt to solve the labyrinth.
     * @param _guess The magic word to bypass Gate 2.
     */
    function solve(bytes32 _guess) external {
        // --- Gate 1: The Mirror ---
        // "Only those who operate from the shadows may enter."
        // Requires usage of a smart contract wallet (ContractCaller), not an EOA.
        require(msg.sender != tx.origin, "Gate 1: Use a proxy.");

        // --- Gate 2: The Riddle ---
        // "What is hidden must be seen."
        // Requires reading private storage slots to find the secret.
        if (_guess != secret) {
            revert("Gate 2: Wrong answer.");
        }

        // --- Gate 3: The Greedy ---
        // "Greed is a slow and insidious killer."
        // A classic re-entrancy honeypot.
        
        // If locked is true, it means we are re-entering.
        // TRAPTRIGGER: Consume all gas.
        if (locked) {
            // Infinite loop to burn gas
            while(true) {}
        }
        
        locked = true;

        // The bait: Sending ETH to the caller.
        // This hands over control flow to the caller.
        (bool success, ) = msg.sender.call{value: 1 wei}("");
        require(success, "ETH transfer failed");

        // The Trap:
        // Ideally, a re-entrancy attack would try to call solve() again here.
        // But since we set `locked = true`, they can't.
        // HOWEVER, the "Trap" part implies we want to punish them if they TRY.
        // In this simple version, the `require(!locked)` above just reverts the re-entrant call.
        // To make it a *Trap* (punishment), we would ideally detect the re-entrancy attempt
        // and consume gas, but standard reentrancy guards just revert.
        
        // Let's implement a nastier trap.
        // Use a balance check. If they tried to steal more (by re-entering), 
        // we could detect it maybe?
        // Actually, for educational clarity, let's keep it simple:
        // The "Trap" is that if they simply try to re-enter naively, they fail.
        // But wait, the roadmap said: "If the attacker tries to re-enter, the trap triggers a SelfDestruct or infinite loop"
        
        // This execution continues AFTER the external call returns.
        
        locked = false;
        
        emit ChallengeSolved(msg.sender, 0); // Sent 1 wei above
    }
    
    // Allow the contract to receive bounties
    receive() external payable {}
}
