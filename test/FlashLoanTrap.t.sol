// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/traps/FlashLoanTrap.sol";

contract FlashLoanTrapTest is Test {
    FlashLoanTrap public trap;
    address public user;

    function setUp() public {
        trap = new FlashLoanTrap();
        user = address(0x1234);
        vm.deal(address(trap), 10 ether); // Seed with liquidity
        vm.deal(user, 5 ether);
    }

    /// @notice Test normal flash loan with proper repayment succeeds
    function test_NormalFlashLoan_Succeeds() public {
        HonestBorrower borrower = new HonestBorrower();
        vm.deal(address(borrower), 1 ether);

        uint256 loanAmount = 1 ether;
        uint256 fee = (loanAmount * 10) / 10000; // 0.1%
        
        borrower.executeFlashLoan(address(trap), loanAmount, fee);
        
        // Trap should have received the fee
        assertGe(address(trap).balance, 10 ether);
    }

    /// @notice Test flash loan without repayment triggers trap
    function test_NoRepayment_TriggersTrap() public {
        MaliciousBorrower attacker = new MaliciousBorrower();
        
        // The trap uses invalid() opcode which causes a revert without data
        vm.expectRevert();
        attacker.executeFlashLoan(address(trap), 1 ether);
    }

    /// @notice Test liquidity query works
    function test_GetAvailableLiquidity() public view {
        assertEq(trap.getAvailableLiquidity(), 10 ether);
    }

    /// @notice Test zero amount reverts
    function test_ZeroAmount_Reverts() public {
        HonestBorrower borrower = new HonestBorrower();
        
        vm.expectRevert("Amount must be > 0");
        trap.flashLoan(0, address(borrower), "");
    }

    /// @notice Test insufficient liquidity reverts  
    function test_InsufficientLiquidity_Reverts() public {
        HonestBorrower borrower = new HonestBorrower();
        
        vm.expectRevert("Insufficient liquidity");
        trap.flashLoan(100 ether, address(borrower), "");
    }
}

/// @notice Honest borrower that repays the loan
contract HonestBorrower {
    function executeFlashLoan(address trap, uint256 amount, uint256 fee) external {
        bytes memory data = abi.encodeWithSignature("onFlashLoan(uint256,uint256)", amount, fee);
        FlashLoanTrap(payable(trap)).flashLoan(amount, address(this), data);
    }

    function onFlashLoan(uint256 amount, uint256 fee) external payable {
        // Repay immediately
        (bool success, ) = msg.sender.call{value: amount + fee}("");
        require(success, "Repayment failed");
    }

    receive() external payable {}
}

/// @notice Malicious borrower that doesn't repay
contract MaliciousBorrower {
    function executeFlashLoan(address trap, uint256 amount) external {
        bytes memory data = abi.encodeWithSignature("steal()");
        FlashLoanTrap(payable(trap)).flashLoan(amount, address(this), data);
    }

    function steal() external payable {
        // Don't repay - keep the funds
    }

    receive() external payable {}
}
