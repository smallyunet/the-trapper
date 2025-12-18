// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/traps/StorageGhost.sol";

contract StorageGhostTest is Test {
    StorageGhost public trap;
    address public victim;
    address public attacker;

    function setUp() public {
        trap = new StorageGhost();
        attacker = address(0xBADC0DE);
        vm.deal(attacker, 10 ether);
        // Initially, the contract works fine.
    }

    // Define a malicious implementation that tries to overwrite owner.
    // In a standard proxy (without collision issues), this would work if it aligns with owner slot.
    // Here, we expect it to trigger the trap.
    function test_ExploitAttempt_FailsOrTraps() public {
        vm.startPrank(attacker);

        // 1. Attacker deploys a malicious implementation
        // This implementation has `owner` at slot 0 (implicit).
        MaliciousImpl impl = new MaliciousImpl();

        // 2. Attacker calls execute() to delegatecall to their malicious impl.
        // Data: updateOwner(attacker)
        bytes memory data = abi.encodeWithSignature("updateOwner(address)", attacker);
        
        // We expect the transaction to revert (TRAPPED) or consume all gas.
        // In our StorageGhost implementation, we have a check `if (trapSlot != 0)`
        // triggered by the delegatecall writing to slot 0.
        
        // Let's verify it reverts with the specific trap behavior (or just reverts).
        vm.expectRevert();
        trap.execute(address(impl), data);

        vm.stopPrank();
    }
}

contract MaliciousImpl {
    // Mimicking the storage layout of a "naiive" proxy where owner is slot 0.
    address public owner; 

    function updateOwner(address _newOwner) external {
        owner = _newOwner;
    }
}
