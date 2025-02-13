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
        if (balanceOf[msg.sender] > balanceOf[top3[0]]) {
            top3[2] = top3[1];
            top3[1] = top3[0];
            top3[0] = msg.sender;
        } else if (balanceOf[msg.sender] > balanceOf[top3[1]]) {
            top3[2] = top3[1];
            top3[1] = msg.sender;
        } else if (balanceOf[msg.sender] > balanceOf[top3[2]]) {
            top3[2] = msg.sender;
        }
    }
    function withdraw(uint256 _amount) public {
        require(msg.sender == owner, "Permission denied");
        require(_amount > 0, "Invalid amount");
        require(address(this).balance >= _amount, "Insufficient balance");
        payable(msg.sender).transfer(_amount);
    }
}