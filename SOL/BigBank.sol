// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IBank {
    function deposit() external payable;
    function withdraw(uint256 _amount) external;
}

contract Bank is IBank {
    mapping(address => uint256) public balanceOf;
    address[3] public top3;
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function deposit() public payable virtual {
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

    // 修改：允许管理员（Admin合约的owner）和合约的owner调用 withdraw
    function withdraw(uint256 _amount) public {
        require(msg.sender == owner || msg.sender == address(this), "Bank Permission denied");
        require(_amount > 0, "Invalid amount");
        require(address(this).balance >= _amount, "Insufficient balance");
        payable(msg.sender).transfer(_amount);
    }
}

contract BigBank is Bank {
    address public BigBankOwner;

    constructor(address _toOwner) {
        BigBankOwner = msg.sender;
        transferOwner(_toOwner);
    }

    modifier CheckAmount(uint256 _amount) {
        require(_amount > 0.001 * 10 ** 18, "amount must be greater than 0.001 ether");
        _;
    }

    function deposit() public payable override CheckAmount(msg.value) {
        super.deposit();
    }

    function transferOwner(address newOwner) private {
        require(msg.sender == owner, "Only the current owner can transfer owner");
        require(newOwner != address(0), "New owner cannot be the zero address");
        BigBankOwner = newOwner;
    }

    // 添加adminWithdraw函数来允许管理员从 BigBank 提取资金
    function adminWithdraw(uint256 _amount) external {
        require(msg.sender == BigBankOwner, "Only BigBankOwner can withdraw");
        withdraw(_amount);
    }
}

contract Admin {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    // adminWithdraw函数，允许管理员从指定的银行合约提取资金
    function adminWithdraw(IBank bank) public {
        require(msg.sender == owner, "Only Admin Owner can call this");
        bank.withdraw(address(this).balance);
    }

    receive() external payable {}
}
