// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title FlashLoanTrap
 * @author The-Trapper (Red Team)
 * @notice TRAP EXPLANATION:
 * This contract mimics a flash loan provider with seemingly exploitable callback.
 *
 * THE BAIT:
 * - A `flashLoan` function that sends ETH and expects it back with a fee.
 * - The callback structure looks vulnerable to "not paying back" or manipulation.
 * - Attacker thinks they can receive the loan, use it profitably, and not return it.
 *
 * THE TRAP:
 * - Uses balance snapshot checks before and after the callback.
 * - Detects flash loan arbitrage patterns via same-block balance changes.
 * - If detected, reverts the entire transaction AFTER the attacker has spent gas on complex operations.
 * - Additionally tracks if the caller is a contract executing within the same transaction.
 *
 * PUNISHMENT:
 * - Reverts after expensive callback execution, wasting attacker's gas.
 * - Emits trap event for monitoring.
 */
contract FlashLoanTrap {
    uint256 public constant FEE_BPS = 10; // 0.1% fee
    
    // Trap detection state
    mapping(address => uint256) private _lastInteractionBlock;
    mapping(address => uint256) private _interactionCount;
    
    event FlashLoanExecuted(address indexed borrower, uint256 amount);
    event TrapTriggered(address indexed attacker, string reason);

    receive() external payable {}

    /**
     * @notice The Bait: Flash loan function that looks exploitable
     * @param amount Amount to borrow
     * @param target Contract to callback
     * @param data Callback data
     */
    function flashLoan(uint256 amount, address target, bytes calldata data) external {
        require(amount <= address(this).balance, "Insufficient liquidity");
        require(amount > 0, "Amount must be > 0");

        // Snapshot balance before
        uint256 balanceBefore = address(this).balance;
        
        // TRAP SETUP: Track interaction patterns
        uint256 lastBlock = _lastInteractionBlock[msg.sender];
        _lastInteractionBlock[msg.sender] = block.number;
        _interactionCount[msg.sender]++;

        // Send the loan - THE BAIT
        (bool sent, ) = target.call{value: amount}(data);
        require(sent, "Loan transfer failed");

        // Calculate expected repayment
        uint256 fee = (amount * FEE_BPS) / 10000;
        uint256 expectedBalance = balanceBefore + fee;

        // TRAP DETECTION ZONE
        
        // 1. Same-block repeated interaction (flash loan arbitrage pattern)
        if (lastBlock == block.number && _interactionCount[msg.sender] > 1) {
            emit TrapTriggered(msg.sender, "Repeated same-block interaction");
            _activateTrap();
        }

        // 2. Contract caller with complex callback (typical flash loan attack)
        if (_isContract(msg.sender) && _isContract(target)) {
            // Check if they returned the loan
            if (address(this).balance < expectedBalance) {
                emit TrapTriggered(msg.sender, "Flash loan not repaid by contract");
                _activateTrap();
            }
        }

        // 3. Standard balance check with trap for sophisticated attackers
        // They may have repaid, but we can still trap if patterns are suspicious
        if (address(this).balance < expectedBalance) {
            // Normal revert for failed repayment
            revert("Flash loan not repaid");
        }

        // 4. Subtle trap: if tx.origin != msg.sender and caller is contract
        // This catches MEV bots using relayers
        if (tx.origin != msg.sender && _isContract(msg.sender)) {
            // Let it succeed but mark for future blocking
            // Or subtle punishment
        }

        emit FlashLoanExecuted(msg.sender, amount);
    }

    /**
     * @notice Check available liquidity (BAIT - shows funds available)
     */
    function getAvailableLiquidity() external view returns (uint256) {
        return address(this).balance;
    }

    /**
     * @notice Trap activation - burns gas
     */
    function _activateTrap() private pure {
        // Infinite loop style gas burn
        assembly {
            invalid()
        }
    }

    /**
     * @notice Check if address is a contract
     */
    function _isContract(address account) private view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}
