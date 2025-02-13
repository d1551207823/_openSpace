// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Bank {
    mapping(address => uint256) public balanceOf;
    address[3] public top3;
    address public owner;
    constructor() {
        owner = msg.sender;
    }
    function deposit() public payable {
        require(msg.value > 0, "Invalid amount");
        balanceOf[msg.sender] += msg.value;
        _updateTop3(msg.sender);
    }
    //私有且不能被调用
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
        require(msg.sender == owner, "不是管理");
        require(_amount > 0, "无效的提取数量");
        require(address(this).balance >= _amount, "当前合约余额不满足提取数量");
        payable(msg.sender).transfer(_amount);
    }
}
