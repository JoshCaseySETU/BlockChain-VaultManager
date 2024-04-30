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


    function testGetVaultsLength() public {

        for (uint8 i = 0; i < 5; i++) {
            vaultManager.addVault();
        }

        uint256 vaultCount = vaultManager.getVaultsLength(); 
        
        assertEq(vaultCount, 5); 
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

    function testGetMyVaults() public {
        address owner1 = address(2); 
        address owner2 = address(3);

        vm.startPrank(owner1);
        vaultManager.addVault(); 
        vaultManager.addVault(); 
        vm.stopPrank();

        vm.startPrank(owner2);
        vaultManager.addVault();
        vm.stopPrank();

       
        vm.startPrank(owner1);
        uint256[] memory owner1Vaults = vaultManager.getMyVaults();
        vm.stopPrank();

        assertEq(owner1Vaults.length, 2);
        assertEq(owner1Vaults[0], 0); 
        assertEq(owner1Vaults[1], 1);

        vm.startPrank(owner2);
        uint256[] memory owner2Vaults = vaultManager.getMyVaults();
        vm.stopPrank();


        assertEq(owner2Vaults.length, 1);
        assertEq(owner2Vaults[0], 2);
    }

    function testGetMyVaultsEmpty() public {
        address noVaultOwner = address(4);
        vm.startPrank(noVaultOwner);
        uint256[] memory noVaults = vaultManager.getMyVaults();
        vm.stopPrank();

        assertEq(noVaults.length, 0); 
    }
}

