// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/traps/StorageGhost.sol";
import "../src/traps/AntiMEV.sol";
import "../src/traps/ReentrancyBait.sol";

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

        vm.stopBroadcast();

        console.log("");
        console.log("=== All traps deployed successfully ===");
    }
}
