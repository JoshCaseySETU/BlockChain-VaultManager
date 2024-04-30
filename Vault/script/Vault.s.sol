// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {VaultManager} from "../src/Vault.sol";


contract VaultManagerScript is Script {
    function setUp() public {}

    function run() public {

        uint256 deployerPrivateKey = vm.envUint("Private_Key");  
        vm.startBroadcast(deployerPrivateKey);  
        VaultManager vaultManager = new VaultManager();  
        console.log("VaultManager deployed at:", address(vaultManager)); 
        vm.stopBroadcast(); 
        
    }
}

