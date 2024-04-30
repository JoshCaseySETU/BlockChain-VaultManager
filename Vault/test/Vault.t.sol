// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {VaultManager, Unauthorised} from "../src/Vault.sol";

contract VaultManagerTest is Test {
    VaultManager public vaultManager; 

    function setUp() public {
        vaultManager = new VaultManager(); 
    }

    function testAddVault() public {
        uint256 vaultIndex = vaultManager.addVault(); 
        assertEq(vaultIndex, 0); 
    }

    function testDeposit() public {
        address depositor = address(1); 
        uint256 initialBalance = 20 ether; 
        vm.deal(depositor, initialBalance); 

        vm.startPrank(depositor);
        uint256 vaultIndex = vaultManager.addVault(); 
        vaultManager.deposit{value: 3 ether}(vaultIndex); 

        VaultManager.Vault memory vault = vaultManager.getVault(vaultIndex); 

        vm.stopPrank(); 

        assertEq(vault.balance, 3 ether);
    }

    //EVM Error Revert: PrecompileOOG (Out Of Gas) no Idea how to fix it :(
    function testWithdraw() public {
        address user = address(1); 
        uint256 initialBalance = 10 ether; 
        vm.deal(user, initialBalance); 
    
        vm.startPrank(user); 

        uint256 vaultIndex = vaultManager.addVault();
 
        vaultManager.deposit{value: 10 ether}(vaultIndex);

        vaultManager.withdraw(vaultIndex, 5 ether);

        VaultManager.Vault memory vault = vaultManager.getVault(vaultIndex);

        vm.stopPrank();

        assertEq(vault.balance, 5 ether);
    }

    function testWithdrawInsufficientFunds() public {
        address user = address(1);
        uint256 initialBalance = 20 ether; 

        vm.deal(user, initialBalance);
        vm.startPrank(user);
    
        uint256 vaultIndex = vaultManager.addVault(); 
        vaultManager.deposit{value: 4 ether}(vaultIndex); 
    
        vm.expectRevert("Insufficient balance"); 
        vaultManager.withdraw(vaultIndex, 6 ether); 

        vm.stopPrank(); 
    }


    function testGetVault() public {
        address user = address(1); // The user who will interact with the vault
        uint256 initialBalance = 20 ether; // The starting ether balance for the user

        vm.deal(user, initialBalance);
        vm.startPrank(user);

        uint256 vaultIndex = vaultManager.addVault();
        VaultManager.Vault memory vault = vaultManager.getVault(vaultIndex);

        assertEq(vault.owner, user, "Vault owner mismatch");
        assertEq(vault.balance, 0 ether, "Vault balance mismatch");
        vm.stopPrank();

    }


    function testGetVaultsLength(uint8 randNo) public {

        for (uint8 i = 0; i < randNo; i++) {
            vaultManager.addVault();
        }

        uint256 vaultCount = vaultManager.getVaultsLength(); 
        
        assertEq(vaultCount, randNo); 
    }

    function testDepositOnlyOwner() public {
        address owner = address(1); 
        address notOwner = address(2); 
    
        vm.deal(owner, 20 ether); 
        vm.startPrank(owner); 
    
        uint256 vaultIndex = vaultManager.addVault(); 
        vm.stopPrank(); 
    
        vm.deal(notOwner, 20 ether); 
        vm.startPrank(notOwner);
    
        vm.expectRevert(Unauthorised.selector); 
        vaultManager.deposit{value: 5 ether}(vaultIndex); 
        vm.stopPrank(); 
    }


    function testWithdrawOnlyOwner() public {
        address owner = address(1); 
        address notOwner = address(2); 

        vm.deal(owner, 20 ether); 
        vm.startPrank(owner); 

        uint256 vaultIndex = vaultManager.addVault(); 
        vaultManager.deposit{value: 5 ether}(vaultIndex); 
        vm.stopPrank(); 

        vm.deal(notOwner, 20 ether); 
        vm.startPrank(notOwner);
    
        vm.expectRevert(Unauthorised.selector); 
        vaultManager.withdraw(vaultIndex, 5 ether);
        vm.stopPrank(); 
    }

    function testMultipleDeposits() public {
        address user = address(1); 
        vm.deal(user, 20 ether); 
        vm.startPrank(user);

        uint256 vaultIndex = vaultManager.addVault(); 
        vaultManager.deposit{value: 2 ether}(vaultIndex); 
        vaultManager.deposit{value: 3 ether}(vaultIndex); 
        vaultManager.deposit{value: 1 ether}(vaultIndex); 
    
        VaultManager.Vault memory vault = vaultManager.getVault(vaultIndex); 
        assertEq(vault.balance, 6 ether, "Vault balance after multiple deposits is incorrect");

        vm.stopPrank();
    }

}
