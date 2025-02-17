// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract BaseERC20 {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        name = "BaseERC20";
        symbol = "BERC20";
        decimals = 18;
        totalSupply = 100000000 * (10 ** uint256(decimals)); // 需要与精度相乘
        balances[msg.sender] = totalSupply;
    }

    function balanceOf(address add) public view returns (uint256 balance) {
        return balances[add];
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value, "ERC20: transfer amount exceeds balance");
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        // 转账事件记录日志
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(balances[_from] >= _value, "ERC20: transfer amount exceeds balance");
        require(allowances[_from][msg.sender] >= _value, "ERC20: transfer amount exceeds allowance");
        balances[_from] -= _value;
        balances[_to] += _value;
        allowances[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowances[_owner][_spender];
    }

    // 新增的转账带有钩子函数
    function transferWithCallback(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value, "ERC20: transfer amount exceeds balance");
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);

        // 如果目标地址是合约地址，调用其 tokensReceived 方法
        if (isContract(_to)) {
            ITokenReceiver(_to).tokensReceived(msg.sender, _value);
        }
        return true;
    }
    // 判断目标地址是否为合约地址
    function isContract(address _address) private view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(_address)
        }
        return size > 0;
    }
}

// 定义接收 Token 的合约接口
interface ITokenReceiver {
    function tokensReceived(address from, uint256 value) external;
}
contract TokenBank {
    BaseERC20 public token;  // Token 合约的实例
    mapping(address => uint256) public balances;  // 存储每个地址存入的 Token 数量

    // 构造函数，初始化 Token 合约地址
    constructor(address _token) {
        token = BaseERC20(_token);  // 初始化 ERC20 合约
    }
    // 存入 Token
    function deposit(uint256 amount) external {
        require(amount > 0, "Deposit amount must be greater than zero");
        // 从用户地址转移 Token 到 TokenBank 合约地址
        require(token.transferFrom(msg.sender, address(this), amount), "Token transfer failed");
        // 更新用户存款余额
        balances[msg.sender] += amount;
    }
    // 提取存入的 Token
    function withdraw(uint256 amount) external {
        require(amount > 0, "Withdrawal amount must be greater than zero");
        require(balances[msg.sender] >= amount, "Insufficient balance");
        // 更新用户存款余额
        balances[msg.sender] -= amount;
        // 转账 Token 给用户
        require(token.transfer(msg.sender, amount), "Token transfer failed");
    }
    // 获取合约的 Token 总余额
    function contractBalance() external view returns (uint256) {
        return token.balanceOf(address(this));
    }
}
contract TokenBankV2 is TokenBank, ITokenReceiver {
    // 在 TokenBankV2 中实现 tokensReceived
    constructor(address _token) TokenBank(_token) {}
    // 实现 tokensReceived 方法，存款记录工作
    function tokensReceived(address from, uint256 value) external override {
        require(msg.sender == address(token), "Only the token contract can call this function");
        balances[from] += value;
    }
}
