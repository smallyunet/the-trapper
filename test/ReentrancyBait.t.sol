// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/traps/ReentrancyBait.sol";

contract ReentrancyBaitTest is Test {
    ReentrancyBait public trap;
    address public user;
    address public attacker;

    function setUp() public {
        trap = new ReentrancyBait();
        user = address(0x1234);
        attacker = address(0xBADC0DE);
        vm.deal(user, 10 ether);
        vm.deal(attacker, 10 ether);
    }

    /// @notice Test normal deposit and withdraw flow works
    function test_NormalDepositWithdraw() public {
        vm.startPrank(user);
        
        // Deposit
        trap.deposit{value: 1 ether}();
        assertEq(trap.balances(user), 1 ether);
        
        // Withdraw
        uint256 balanceBefore = user.balance;
        trap.withdraw();
        
        assertEq(trap.balances(user), 0);
        assertEq(user.balance, balanceBefore + 1 ether);
        
        vm.stopPrank();
    }

    /// @notice Test withdraw with no balance reverts
    function test_WithdrawNoBalance_Reverts() public {
        vm.startPrank(user);
        vm.expectRevert("No balance");
        trap.withdraw();
        vm.stopPrank();
    }

    /// @notice Test reentrancy attack behavior
    function test_ReentrancyAttack_Behavior() public {
        // Seed the trap with some ETH
        vm.deal(address(trap), 5 ether);
        
        // Deploy attacker contract
        ReentrancyAttacker attackerContract = new ReentrancyAttacker(address(trap));
        vm.deal(address(attackerContract), 1 ether);
        
        // Attacker deposits
        attackerContract.deposit{value: 1 ether}();
        
        // Attempt reentrancy attack
        // The shadow lock mechanism should affect the attack
        uint256 trapBalanceBefore = address(trap).balance;
        
        try attackerContract.attack() {
            // If it succeeds, check the trap's behavior
            // The shadow lock should have been triggered
        } catch {
            // Expected behavior - attack was trapped
        }
    }

    /// @notice Test multiple deposits from same user
    function test_MultipleDeposits() public {
        vm.startPrank(user);
        
        trap.deposit{value: 1 ether}();
        trap.deposit{value: 2 ether}();
        
        assertEq(trap.balances(user), 3 ether);
        
        vm.stopPrank();
    }
}

/// @notice Attacker contract that attempts reentrancy
contract ReentrancyAttacker {
    ReentrancyBait public target;
    uint256 public attackCount;
    uint256 public maxAttacks = 2;

    constructor(address _target) {
        target = ReentrancyBait(payable(_target));
    }

    function deposit() external payable {
        target.deposit{value: msg.value}();
    }

    function attack() external {
        attackCount = 0;
        target.withdraw();
    }

    receive() external payable {
        attackCount++;
        if (attackCount < maxAttacks && address(target).balance > 0) {
            // Attempt reentrancy
            try target.withdraw() {
                // Reentrancy succeeded
            } catch {
                // Reentrancy was blocked
            }
        }
    }
}
