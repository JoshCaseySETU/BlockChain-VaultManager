//Author: Josh Casey, C00261828
//Date: 01/05/2024
//Reference: Jakub Zurakowski "https://github.com/ZurakowskiJakub/vault-manager"
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;


import "forge-std/console.sol";


error Unauthorised();

contract VaultManager {
    struct Vault {
        address owner;  
        uint256 balance;  
    }

   
    Vault[] public vaults;

    mapping(address => uint256[]) public vaultsByOwner;

    event VaultAdded(uint256 indexed vaultId, address owner);
    event VaultDeposited(uint256 indexed vaultId, address depositor, uint256 amount);
    event VaultWithdrawn(uint256 indexed vaultId, address withdrawer, uint256 amount);

    modifier onlyOwner(uint256 vaultId) {
        if (vaults[vaultId].owner != msg.sender) {
            revert Unauthorised();
        }
        _; 
    }

    function addVault() public returns (uint256 vaultId) {
        Vault memory newVault = Vault({
            owner: msg.sender,
            balance: 0
        });

        vaults.push(newVault);  
        vaultId = vaults.length - 1; 
        vaultsByOwner[msg.sender].push(vaultId);  
        emit VaultAdded(vaultId, msg.sender); 
    }

    function deposit(uint256 vaultId) public payable onlyOwner(vaultId) {
        require(vaultId < vaults.length, "Invalid vault ID"); 
        require(msg.value > 0, "Must deposit a positive amount");

        vaults[vaultId].balance += msg.value;  

        emit VaultDeposited(vaultId, msg.sender, msg.value); 
    }

    function withdraw(uint256 vaultId, uint256 amount) public onlyOwner(vaultId) {
        require(vaultId < vaults.length, "Invalid vault ID");
        require(amount > 0, "Amount must be greater than zero");

        Vault storage vault = vaults[vaultId];

        require(vault.balance >= amount, "Insufficient balance");

        vault.balance -= amount;

        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Transfer failed");

        emit VaultWithdrawn(vaultId, msg.sender, amount);
}


    function getVault(uint256 vaultId) public view returns (Vault memory) {
        return vaults[vaultId];
    }

    function getVaultsLength() public view returns (uint256) {
        return vaults.length;
    }

    function getMyVaults() public view returns (uint256[] memory) {
        return vaultsByOwner[msg.sender];
    }
}
