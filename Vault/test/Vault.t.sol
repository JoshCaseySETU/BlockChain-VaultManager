// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {VaultManager, Unauthorised} from "../src/Vault.sol";

contract VaultManagerTest is Test {
    VaultManager public vaultManager; // Declare an instance of VaultManager

    function setUp() public {
        vaultManager = new VaultManager(); // Initialize the VaultManager
    }

    // Test adding a new vault and verify its index
    function testAddVault() public {
        uint256 vaultIndex = vaultManager.addVault(); // Add a vault
        assertEq(vaultIndex, 0); // Ensure the index is correct (first vault)
    }

    // Test depositing into a vault
    function testDeposit() public {
        address depositor = address(1); // Simulate a depositor
        uint256 initialBalance = 20 ether;
        startHoax(depositor, initialBalance); // Start hoax with known user and balance

        uint256 vaultIndex = vaultManager.addVault(); // Create a vault
        vaultManager.deposit{value: 3 ether}(vaultIndex); // Deposit into the vault

        VaultManager.Vault memory vault = vaultManager.getVault(vaultIndex); // Get vault details

        vm.stopPrank(); // Stop hoax context

        assertEq(vault.balance, 3 ether); // Ensure balance matches the deposit
    }

    // Test withdrawing from a vault
    function testWithdraw() public {
        address user = address(1); 
        startHoax(user, 200 ether); 
        uint256 vaultIndex = vaultManager.addVault(); 
        vaultManager.deposit{value: 5 ether}(vaultIndex);
        vaultManager.withdraw(vaultIndex, 1 ether); 
        VaultManager.Vault memory vault = vaultManager.getVault(vaultIndex); 
        vm.stopPrank();
        assertEq(vault.balance, 4 ether);
}

    // Test withdrawing with insufficient balance
    function testWithdrawInsufficientFunds() public {
        address user = address(1);
        startHoax(user, 20 ether); // Start with user context
        
        uint256 vaultIndex = vaultManager.addVault(); // Create a vault
        vaultManager.deposit{value: 4 ether}(vaultIndex); // Deposit into the vault

        vm.expectRevert("Insufficient balance"); // Expect revert
        vaultManager.withdraw(vaultIndex, 6 ether); // Attempt to withdraw more than balance
        
        vm.stopPrank(); // End context
    }

    // Test retrieving vault details
    function testGetVault() public {
        address user = address(1);
        startHoax(user, 20 ether); // Start with user context
        
        uint256 vaultIndex = vaultManager.addVault(); // Create a vault

        VaultManager.Vault memory vault = vaultManager.getVault(vaultIndex); // Get vault details

        vm.stopPrank(); // End context

        assertEq(vault.owner, user); // Ensure the correct owner
        assertEq(vault.balance, 0 ether); // Ensure the initial balance is zero
    }

    // Test getting the total number of vaults
    function testGetVaultsLength(uint8 randNo) public {
        // Create multiple vaults
        for (uint8 i = 0; i < randNo; i++) {
            vaultManager.addVault();
        }

        uint256 vaultCount = vaultManager.getVaultsLength(); // Get the vault count
        
        assertEq(vaultCount, randNo); // Ensure the count matches the number of vaults created
    }

    // Test deposit only allowed for the vault owner
    function testDepositOnlyOwner() public {
        address owner = address(1);
        address notOwner = address(2);

        startHoax(owner, 20 ether); // Start with owner context
        uint256 vaultIndex = vaultManager.addVault(); // Owner creates a vault
        vm.stopPrank(); // End context

        startHoax(notOwner, 20 ether); // Simulate a different user (non-owner)
        vm.expectRevert(Unauthorised.selector); // Expecting unauthorized revert
        vaultManager.deposit{value: 5 ether}(vaultIndex); // Non-owner attempts deposit
        vm.stopPrank(); // End context
    }

    // Test withdrawal only allowed for the vault owner
    function testWithdrawOnlyOwner() public {
        address owner = address(1);
        address notOwner = address(2);

        startHoax(owner, 20 ether); // Start with owner context
        uint256 vaultIndex = vaultManager.addVault(); // Owner creates a vault
        vaultManager.deposit{value: 5 ether}(vaultIndex); // Owner deposits
        vm.stopPrank(); // End the owner context
        
        startHoax(notOwner, 20 ether); // Simulate a different user (non-owner)
        vm.expectRevert(Unauthorised.selector); // Expecting unauthorized revert
        vaultManager.withdraw(vaultIndex, 5 ether); // Non-owner attempts withdrawal
        vm.stopPrank(); // End context
    }
}
