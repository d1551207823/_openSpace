// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

contract Crowdfunding {
    address public owner; // 合约拥有者（创建者）
    uint256 public startTime;
    uint256 public deadline;
    uint256 public targetFund;
    uint256 public currentFund;
    mapping(address => uint256) public funders;

    event FundEvent(address indexed _from, uint256 _value);
    event RefundEvent(address indexed _to, uint256 _value);
    event WithdrawEvent(address indexed _owner, uint256 _value);

    // 合约构造函数
    constructor(uint256 _targetFund, uint256 _duration) {
        owner = msg.sender; // 记录合约创建者
        startTime = block.timestamp;
        deadline = startTime + _duration;
        targetFund = _targetFund;
    }

    // 众筹捐款
    function fund() public payable {
        require(block.timestamp < deadline, "Crowdfunding is over");
        require(msg.value > 0, "Invalid amount");

        currentFund += msg.value;
        funders[msg.sender] += msg.value;
        emit FundEvent(msg.sender, msg.value);
    }

    // 捐款者退款（只有目标资金未达成时）
    function refund() public {
        require(block.timestamp >= deadline, "Crowdfunding is not over");
        require(currentFund < targetFund, "Target fund is reached");
        uint256 amount = funders[msg.sender];
        require(amount > 0, "No fund to refund");
        funders[msg.sender] = 0; // 防止重入攻击
        payable(msg.sender).transfer(amount);
        emit RefundEvent(msg.sender, amount);
    }

    // 合约创建者提取资金
    function withdraw() public {
        require(msg.sender == owner, "Only the owner can withdraw");
        require(block.timestamp >= deadline, "Crowdfunding is not over");
        require(currentFund >= targetFund, "Target fund not reached");

        uint256 amount = currentFund;
        currentFund = 0; // 防止重入攻击
        payable(owner).transfer(amount);
        emit WithdrawEvent(owner, amount);
    }

    // 查询捐款信息
    function getFunderInfo(address _funder) public view returns (uint256) {
        return funders[_funder];
    }

    modifier onlyOwner(uint256 _amount) {
        require(_amount > 0.001 * 10 ** 18, "amount must be greater than 0.001 ether");
        _;
    }
}
