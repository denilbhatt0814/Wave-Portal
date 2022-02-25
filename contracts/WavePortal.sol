// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract WavePortal {
    // used to generate a random number
    uint256 private seed;

    uint256 totalWaves;

    // Event declaration : for logging to blockchain
    // UseCases: Listen to events, update UI, cheap form of storage
    // Up to 3 parameters can be indexed.
    // Indexed parameters helps you filter the logs by the indexed parameter
    event NewWave(address indexed from, uint256 timestamp, string message);

    struct Wave {
        address waver;      // address of user waving
        string message;     // msg from user
        uint256 timestamp;  // when user waved
    }

    // creating an array of wave(struct) to 
    // store all the waves ever sent
    Wave[] waves;

    /*
     * This is an address => uint mapping
     * In this case, we'll be storing the address with the last time the user waved at us.
     */
    mapping(address => uint256) public lastWavedAt;

    constructor() payable {
        console.log("Yo yo, I am a contract and I am excited to do wonders ;)");

        // setting initial seed
        seed = (block.timestamp + block.difficulty)%100;
    }

    function wave(string memory _message) public {

        /*
         * We need to check the current timestamp is at least 5-minutes bigger than the last timestamp we stored
         */
        require(
            lastWavedAt[msg.sender] + 5 minutes < block.timestamp,
            "Wait 5m"
        );

        // updating the current timestamp of user waving
        lastWavedAt[msg.sender] = block.timestamp;

        totalWaves += 1;
        console.log("%s waved w/ message: %s", msg.sender, _message);

        // adding wave to waves array
        waves.push(Wave(msg.sender, _message, block.timestamp));

        // generate new seed for next user
        seed = (block.timestamp + block.difficulty + seed)%100;
        console.log("Random # generated: %d", seed);

        // setting 50% chance for a user to win 
        if (seed <= 50){
            console.log("%s won!", msg.sender);
            // send the prizeAmount
            uint256 prizeAmount = 0.0001 ether;
            require(
                prizeAmount < address(this).balance,
                "Trying to withdraw more ether than the contract has."
            );
            (bool success, ) = (msg.sender).call{value: prizeAmount}("");
            require(success, "Failed to withdraw money from contract");
        }

        // emiting NewWave event
        emit NewWave(msg.sender, block.timestamp, _message);

        
    }

    // getAllWaves is meant to return a array of struct Wave 
    // containing all the waves ever made
    function getAllWaves() public view returns(Wave[] memory){
        return waves; 
    }


    function getTotalWaves() public view returns(uint256){
        console.log("we have %d total waves!", totalWaves);
        return totalWaves;
    }
}