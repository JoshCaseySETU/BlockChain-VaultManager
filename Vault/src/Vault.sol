//Author: Josh Casey
// Date: 30/4/2024
//Aspects of the code inspired by Jakub Zurakowski, Vault Manager on there GitHub, "https://github.com/ZurakowskiJakub/vault-manager".
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Importing console.sol for debugging/logging (if needed)
import "forge-std/console.sol";

// Error for unauthorized access
error Unauthorised();

contract VaultManager {
    // Structure for a Vault
    struct Vault {
        address owner;  // Owner of the vault
        uint256 balance;  // Balance in the vault
    }

    // Array to store all vaults
    Vault[] public vaults;

    // Mapping to store vaults by owner
    mapping(address => uint256[]) public vaultsByOwner;

    // Events for vault operations
    event VaultAdded(uint256 indexed vaultId, address owner);
    event VaultDeposited(uint256 indexed vaultId, address depositor, uint256 amount);
    event VaultWithdrawn(uint256 indexed vaultId, address withdrawer, uint256 amount);

    // Modifier to ensure only the vault owner can access certain functions
    modifier onlyOwner(uint256 vaultId) {
        if (vaults[vaultId].owner != msg.sender) {
            revert Unauthorised();
        }
        _; // Continue with the rest of the function
    }

    // Function to add a new vault
    function addVault() public returns (uint256 vaultId) {
        Vault memory newVault = Vault({
            owner: msg.sender,
            balance: 0
        });

        vaults.push(newVault);  // Add the new vault to the vaults array
        vaultId = vaults.length - 1;  // Get the index of the new vault

        vaultsByOwner[msg.sender].push(vaultId);  // Add the vault ID to the owner's list

        emit VaultAdded(vaultId, msg.sender);  // Emit event for adding a vault
    }

    // Function to deposit into a vault
    function deposit(uint256 vaultId) public payable onlyOwner(vaultId) {
        vaults[vaultId].balance += msg.value;  // Add the deposit amount to the vault's balance

        emit VaultDeposited(vaultId, msg.sender, msg.value);  // Emit event for deposit
    }

    // Function to withdraw from a vault
    function withdraw(uint256 vaultId, uint256 amount) public onlyOwner(vaultId) {
        Vault storage vault = vaults[vaultId];

        if (vault.balance < amount) {
            revert("Insufficient balance");  // Revert if not enough balance
        }

        vault.balance -= amount;  // Decrease the vault's balance
        payable(msg.sender).transfer(amount);  // Transfer the amount to the owner

        emit VaultWithdrawn(vaultId, msg.sender, amount);  // Emit event for withdrawal
    }

    // Function to get details of a specific vault
    function getVault(uint256 vaultId) public view returns (Vault memory) {
        return vaults[vaultId];
    }

    // Function to get the total number of vaults
    function getVaultsLength() public view returns (uint256) {
        return vaults.length;
    }

    // Function to get vaults belonging to the calling user
    function getMyVaults() public view returns (uint256[] memory) {
        return vaultsByOwner[msg.sender];
    }
}
