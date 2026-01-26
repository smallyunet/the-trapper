// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/traps/SpiderAndFly.sol";

contract SpiderAndFlyTest is Test {
    function test_EOA_LowGas_Reverts() public {
        SpiderAndFly trap = new SpiderAndFly();
        vm.deal(address(trap), 1 ether);

        address user = makeAddr("user");
        vm.deal(user, 1 ether);

        vm.prank(user, user);
        vm.txGasPrice(10 gwei);
        vm.expectRevert("Conditions changed");
        trap.claimProfit();

        assertEq(trap.balanceOf(user), 0);
        assertEq(address(trap).balance, 1 ether);
    }

    function test_EOA_HighGas_GetsCaughtAndMinted() public {
        SpiderAndFly trap = new SpiderAndFly();
        vm.deal(address(trap), 1 ether);

        address bot = makeAddr("bot");
        vm.deal(bot, 1 ether);

        vm.prank(bot);
        vm.txGasPrice(100 gwei);
        trap.claimProfit();

        assertEq(trap.balanceOf(bot), 1);
        assertEq(trap.ownerOf(1), bot);
        assertEq(address(trap).balance, 1 ether);
    }

    function test_ContractCaller_GetsCaughtAndMinted() public {
        SpiderAndFly trap = new SpiderAndFly();
        vm.deal(address(trap), 1 ether);

        MevBot bot = new MevBot(address(trap));

        // Call from an EOA into the bot contract; target sees msg.sender as a contract.
        vm.txGasPrice(1 gwei);
        bot.attack();

        assertEq(trap.balanceOf(address(bot)), 1);
        assertEq(trap.ownerOf(1), address(bot));
    }
}

contract MevBot {
    SpiderAndFly private immutable target;

    constructor(address _target) {
        target = SpiderAndFly(payable(_target));
    }

    function attack() external {
        target.claimProfit();
    }
}
