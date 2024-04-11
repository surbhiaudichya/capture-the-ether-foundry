// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/TokenSale.sol";
import "forge-std/console.sol";

contract TokenSaleTest is Test {
    TokenSale public tokenSale;
    ExploitContract public exploitContract;

    function setUp() public {
        // Deploy contracts
        tokenSale = (new TokenSale){value: 1 ether}();
        exploitContract = new ExploitContract(tokenSale);
        vm.deal(address(exploitContract), 4 ether);
    }

    // Use the instance of tokenSale and exploitContract
    /*
    * Determine the number of tokens to buy in order to cause overflow. 
    * We have to get the maximum possible uint256 = 2**256 - 1, then divide it by 1 ether = 10**18.
    * This step is needed because the require verification in the sell function multiplies the numTokens by 10**18.
    * Then, we add 1 to the maxUint256, to ensure that when multiplied by 1 ether, it causes an overflow.
    * Knowing that the overflow will happen, we need to know by how much in order to send the correct msg.value.
    * We have established that: ((2**256/10**18) + 1) * 10**18 = overflow. So, the difference overflow - (maxUint256 + 1) = msg.value needed.
    */
    function testIncrement() public {
        // Put your solution here

        exploitContract.exploit();
        _checkSolved();
    }

    function _checkSolved() internal {
        assertTrue(tokenSale.isComplete(), "Challenge Incomplete");
    }

    receive() external payable {}
}
