// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Bank {
    mapping(address => uint256) public balanceOf;
    address[3] public top3;
    address public owner;
    constructor() {
        owner = msg.sender;
    }
    //加入合约转移函数
    function transferOwner(address newOwner) public {
        require(msg.sender == owner, "Only the current owner can transfer owner");
        require(newOwner != address(0), "New owner cannot be the zero address");
        owner = newOwner;
    }
    function deposit() public payable virtual  {
        require(msg.value > 0, "Invalid amount");
        balanceOf[msg.sender] += msg.value;
        _updateTop3(msg.sender);
    }
    function _updateTop3(address user) private {
        uint256 userBalance = balanceOf[user];
        if (userBalance > balanceOf[top3[0]]) {
            // 用户成为第一名
            top3[2] = top3[1];
            top3[1] = top3[0];
            top3[0] = user;
        } else if (userBalance > balanceOf[top3[1]]) {
            // 用户成为第二名
            top3[2] = top3[1];
            top3[1] = user;
        } else if (userBalance > balanceOf[top3[2]]) {
            // 用户成为第三名
            top3[2] = user;
        }
    }
    function withdraw(uint256 _amount) public {
        require(msg.sender == owner, "Permission denied");
        require(_amount > 0, "Invalid amount");
        require(address(this).balance >= _amount, "Insufficient balance");
        payable(msg.sender).transfer(_amount);
    }
}

contract BigBank is  Bank {
    modifier CheckAmount(uint256 _amount) {
        require(_amount > 0.001 * 10 ** 18, "amount must be greater than 0.001 ether");
        _;
    }
    function deposit() public payable override CheckAmount(msg.value) {
        super.deposit();
    }
}

contract Admin {
    Bank public bank;
    constructor(Bank _bank) {
        bank = _bank;
        bank.transferOwner(msg.sender);
    }
    function withdraw(uint256 _amount) public {
        require(msg.sender == bank.owner(), "Permission denied");
        bank.withdraw(_amount);
    }
}



