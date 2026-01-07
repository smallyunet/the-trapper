// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/traps/TheLabyrinth.sol";

contract TheLabyrinthTest is Test {
    TheLabyrinth public labyrinth;
    address public attacker;

    function setUp() public {
        labyrinth = new TheLabyrinth{value: 1 ether}();
        attacker = makeAddr("attacker");
    }

    // --- Gate 1 Tests ---

    function test_Gate1_RevertIfEOA() public {
        vm.startPrank(attacker, attacker); // msg.sender == tx.origin
        
        // We need to guess something for Gate 2, but Gate 1 should fail first.
        bytes32 guess = bytes32(0);
        
        vm.expectRevert("Gate 1: Use a proxy.");
        labyrinth.solve(guess);
        
        vm.stopPrank();
    }

    // --- Gate 2 Tests ---

    function test_Gate2_RevertIfWrongSecret() public {
        // Use a contract caller to bypass Gate 1
        Solver solver = new Solver(address(labyrinth));
        
        bytes32 wrongSecret = bytes32(uint256(1));
        
        vm.expectRevert("Gate 2: Wrong answer.");
        solver.attemptSolve(wrongSecret);
    }

    // --- Full Success Test ---

    function test_SolveSuccess() public {
        Solver solver = new Solver(address(labyrinth));
        
        // Read the private secret slot (Slot 0)
        bytes32 secret = vm.load(address(labyrinth), bytes32(uint256(0)));
        
        // Expect the ChallengeSolved event
        // Note: We can't easily check events from the inner call without more plumbing,
        // but we can check if it didn't revert.
        
        solver.attemptSolve(secret);
    }

    // --- Gate 3 Trap Test ---

    function test_Gate3_GasTrap() public {
        GreedySolver greedy = new GreedySolver(address(labyrinth));
        
        bytes32 secret = vm.load(address(labyrinth), bytes32(uint256(0)));
        
        // The greedy solver tries to re-enter.
        // We expect the transaction to run out of gas.
        // In Foundry, "OutOfGas" might be the revert reason or it just fails.
        // We can limit gas to avoid hanging the test runner forever if it was real,
        // but vm.expectRevert with out of gas is tricky.
        // Usually, infinite loops trigger an OutOfGas error eventually.
        
        // Let's verify that it fails.
        vm.expectRevert(); // It should revert due to OOG or manual revert if we had one
        greedy.attemptSolve(secret);
    }
}

contract Solver {
    TheLabyrinth public target;
    
    constructor(address _target) {
        target = TheLabyrinth(payable(_target));
    }
    
    function attemptSolve(bytes32 _secret) external {
        target.solve(_secret);
    }
    
    // Fallback to receive ETH from Gate 3
    receive() external payable {}
}

contract GreedySolver {
    TheLabyrinth public target;
    bytes32 public secret;
    
    constructor(address _target) {
        target = TheLabyrinth(payable(_target));
    }
    
    function attemptSolve(bytes32 _secret) external {
        secret = _secret;
        target.solve(_secret);
    }
    
    // Fallback attempts to re-enter
    receive() external payable {
        // Try to call solve again
        // We use a low-level call to allow the OOG to propagate up or be caught?
        // Actually, if we call directly:
        target.solve(secret);
    }
}
