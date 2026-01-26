// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/traps/StorageGhost.sol";
import "../src/traps/AntiMEV.sol";
import "../src/traps/FlashLoanTrap.sol";
import "../src/traps/HoneypotToken.sol";
import "../src/traps/HotPotato.sol";
import "../src/traps/ReentrancyBait.sol";
import "../src/traps/TheLabyrinth.sol";
import "../src/traps/SpiderAndFly.sol";

/**
 * @title DeployTraps
 * @notice Deploys all honeypot traps and seeds them with ETH bait
 * 
 * Usage:
 *   anvil &
 *   forge script script/DeployTraps.s.sol --rpc-url http://localhost:8545 --broadcast
 */
contract DeployTraps is Script {
    uint256 constant BAIT_AMOUNT = 0.1 ether;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        vm.startBroadcast(deployerPrivateKey);

        // Deploy StorageGhost
        StorageGhost storageGhost = new StorageGhost();
        console.log("StorageGhost deployed at:", address(storageGhost));

        // Deploy FlashLoanTrap with bait liquidity
        FlashLoanTrap flashLoanTrap = new FlashLoanTrap();
        (bool fl, ) = address(flashLoanTrap).call{value: BAIT_AMOUNT}("");
        require(fl, "Failed to fund FlashLoanTrap");
        console.log("FlashLoanTrap deployed at:", address(flashLoanTrap));
        console.log("  Funded with:", BAIT_AMOUNT);

        // Deploy HoneypotToken
        HoneypotToken honeypotToken = new HoneypotToken();
        console.log("HoneypotToken deployed at:", address(honeypotToken));

        // Deploy HotPotato
        HotPotato hotPotato = new HotPotato();
        console.log("HotPotato deployed at:", address(hotPotato));
        
        // Deploy AntiMEV with bait
        AntiMEV antiMev = new AntiMEV();
        (bool s1, ) = address(antiMev).call{value: BAIT_AMOUNT}("");
        require(s1, "Failed to fund AntiMEV");
        console.log("AntiMEV deployed at:", address(antiMev));
        console.log("  Funded with:", BAIT_AMOUNT);

        // Deploy ReentrancyBait with bait
        ReentrancyBait reentrancyBait = new ReentrancyBait();
        reentrancyBait.deposit{value: BAIT_AMOUNT}();
        console.log("ReentrancyBait deployed at:", address(reentrancyBait));
        console.log("  Funded with:", BAIT_AMOUNT);

        // Deploy TheLabyrinth with bounty
        TheLabyrinth labyrinth = new TheLabyrinth{value: BAIT_AMOUNT}();
        console.log("TheLabyrinth deployed at:", address(labyrinth));
        console.log("  Funded with:", BAIT_AMOUNT);

        // Deploy SpiderAndFly with bait
        SpiderAndFly spiderAndFly = new SpiderAndFly{value: BAIT_AMOUNT}();
        console.log("SpiderAndFly deployed at:", address(spiderAndFly));
        console.log("  Funded with:", BAIT_AMOUNT);

        vm.stopBroadcast();

        console.log("");
        console.log("=== All traps deployed successfully ===");
    }
}
