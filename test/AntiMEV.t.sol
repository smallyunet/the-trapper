// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/traps/AntiMEV.sol";

contract AntiMEVTest is Test {
    AntiMEV public trap;
    address public attacker;

    function setUp() public {
        trap = new AntiMEV();
        attacker = address(0xBADC0DE);
        vm.deal(attacker, 10 ether);
        vm.deal(address(trap), 1 ether); // Seed the trap with ETH bait
    }

    /// @notice Test that high gas price triggers the trap (gas bomb)
    function test_HighGasPrice_TriggersGasBomb() public {
        vm.startPrank(attacker);
        
        // Set gas price above SECRET_THRESHOLD (50 gwei)
        vm.txGasPrice(100 gwei);
        
        // The trap should emit Gotcha and burn gas
        // We expect it to run out of gas or take excessive gas
        uint256 gasBefore = gasleft();
        
        // Call with limited gas to observe the burn
        try trap.claimProfit{gas: 100000}() {
            // Should not succeed
            fail("Expected revert or gas exhaustion");
        } catch {
            // Expected: either reverts or runs out of gas
        }
        
        vm.stopPrank();
    }

    /// @notice Test that normal gas price just reverts gracefully
    function test_NormalGasPrice_RevertsGracefully() public {
        vm.startPrank(attacker);
        
        // Set normal gas price below threshold
        vm.txGasPrice(10 gwei);
        
        // Should revert with "Conditions changed" (the bait logic)
        vm.expectRevert("Conditions changed");
        trap.claimProfit();
        
        vm.stopPrank();
    }

    /// @notice Test that contract can receive ETH
    function test_CanReceiveETH() public {
        uint256 balanceBefore = address(trap).balance;
        
        vm.deal(address(this), 1 ether);
        (bool success, ) = address(trap).call{value: 0.5 ether}("");
        
        assertTrue(success, "ETH transfer should succeed");
        assertEq(address(trap).balance, balanceBefore + 0.5 ether);
    }

    /// @notice Test empty contract reverts
    function test_EmptyContract_Reverts() public {
        // Deploy new empty trap
        AntiMEV emptyTrap = new AntiMEV();
        
        vm.txGasPrice(10 gwei);
        vm.expectRevert("No funds");
        emptyTrap.claimProfit();
    }
}

/// @notice Attacker contract that tries to exploit via contract call
contract MevBotAttacker {
    AntiMEV public target;
    
    constructor(address _target) {
        target = AntiMEV(payable(_target));
    }
    
    function attack() external {
        target.claimProfit();
    }
}
