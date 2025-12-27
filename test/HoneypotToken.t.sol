// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {HoneypotToken} from "../src/traps/HoneypotToken.sol";

contract HoneypotTokenTest is Test {
    HoneypotToken public token;
    address public owner;
    address public victim;
    address public otherParams;

    function setUp() public {
        owner = address(this);
        victim = address(0xBEEF);
        otherParams = address(0xCAFE);
        
        token = new HoneypotToken();
    }

    function test_OwnerCanTransfer() public {
        token.transfer(victim, 100 * 10**18);
        assertEq(token.balanceOf(victim), 100 * 10**18);
    }

    function test_VictimCannotTransferOut() public {
        // First owner sends some to victim (this should work)
        token.transfer(victim, 100 * 10**18);
        
        // Impersonate victim
        vm.prank(victim);
        
        // Victim tries to send to someone else (e.g. back to owner or a pair)
        vm.expectRevert("TrasferHelper: TRANSFER_FAILED");
        token.transfer(otherParams, 50 * 10**18);
    }

    function test_VictimCanReceive() public {
        token.transfer(victim, 100 * 10**18);
        assertEq(token.balanceOf(victim), 100 * 10**18);
        
        // Another transfer to victim
        token.transfer(victim, 50 * 10**18);
        assertEq(token.balanceOf(victim), 150 * 10**18);
    }
}
