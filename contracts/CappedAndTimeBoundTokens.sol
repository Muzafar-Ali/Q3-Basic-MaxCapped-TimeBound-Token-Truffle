// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender,address recipient,uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract EducationToken is IERC20{
    string _name;
    string _symbol;
    uint256 _decimals;
    uint256 _totalSupply;
    address _owner;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowances;
    
    constructor(){
        _name ="Education Token";
        _symbol = "ECT";
        _decimals = 18;
        _totalSupply = 1000000 *10**_decimals;
        _owner = msg.sender;
        balances[_owner] = _totalSupply;
    }

    function totalSupply() external view override returns (uint256){
        return _totalSupply;       
    }
    
    function balanceOf(address account) external view override returns (uint256){
        return balances[account];
    }
    
    function transfer(address recipient, uint256 amount) external override returns (bool){
        require(recipient !=address(0),"ERROR: sending to Zero address");
        require(msg.sender !=address(0),"ERROR: sending from Zero address");
        require(balances[msg.sender] >= amount,"ERROR: Not enough balance to Transfer");
        require( amount > 0,"ERROR: sending zero amount");
        
        balances[msg.sender] = balances[msg.sender] - amount;
        balances[recipient]  = balances[recipient] + amount;
        
        emit Transfer(msg.sender,recipient,amount);
        return true;
    }

    function allowance(address owner, address spender) external view override returns (uint256){
        return allowances[owner][spender]; 
    }

    function approve(address spender, uint256 amount) external override returns (bool){
        require(spender !=address(0),"ERROR:approve from Zero address");
        require(msg.sender !=address(0),"ERROR: apprive to Zero address");
        require(balances[msg.sender] >=amount,"ERROR: dont have enough tokens");
        require(amount > 0, "ERROR: assignment should be more tha Zero");
        
        allowances[msg.sender][spender] = amount;
        
        emit Approval(msg.sender,spender,amount);
        return true;       
    }
    
    function transferFrom(address sender,address recipient,uint256 amount) external override returns (bool){
        
        require(recipient !=address(0),"ERROR: sending to Zero address");
        require(msg.sender !=address(0),"ERROR: sending from Zero address");
        require(allowances[sender][recipient] >= amount,"ERROR: Not enough balance to Transfer");
        require( amount > 0,"ERROR: sending zero amount");
        
        allowances[msg.sender][sender] -= amount;
        
        balances[msg.sender] = balances[msg.sender] - amount;
        balances[recipient]  = balances[recipient] + amount;
        
        emit Transfer(msg.sender,recipient,amount); 
        return true;
        
    }
}


// Please complete the ERC20 token with the following extensions;
// 1) - Capped Token: The minting token should not be exceeded from the Capped limit.
// 2) - TimeBound Token: The token will not be transferred until the given time exceed. For example Wages payment will be due after 30 days.
// 3) should be deployed by using truffle or hardhat on any Ethereum test network
contract CappedAndTimeBoundTokens is EducationToken{

    uint256 public tokenCap; 
    // date token  minted for salary
    uint256 mintedOn;
    
    constructor(){
         tokenCap = _totalSupply + (500000 *10**_decimals);
    }
    
    // modifier will restrict transfer of funds for 30 days from the date of mintTokensForSalary function is called;
    modifier transferAfterMonth(){
        uint256 transferOn = 2629743 +  mintedOn ; // date when token will become tranferable i.e 30 days
        require(block.timestamp > transferOn && mintedOn > 0,"ERROR: Wait: Transfer date not reached  ");
        _;
    }  
    
    // to hold tokens minted for salary for temporary period
    // once slary transfer  function is called all balances will be transferred to balances mappping  
    address[] tempArrayofAdd;
    mapping(address => uint256) temporaryStay; // it will hold balances for 30 days
    
    // this mint is used for normal minting of tokens except salaries there is no time limit for these transfers
    // in this mint there is no binding of holding tokens for specific date
    function mint(address account, uint256 amount)public returns(bool){
        require(_owner == msg.sender, "ERROR: You cant Mint Tokens");
        require(account !=address(0),"ERROR:Mintin to zero Address");
        require(_totalSupply + amount <= tokenCap,"ERROR: Reached the token cap");
    
        
        balances[account] += amount;
    
        _totalSupply += amount;

        emit Transfer(address(0), account, amount);      
        return true;  
    }
    
    // this mint is only called for salaries, it will help to hold tokens for 30 days 
    function mintForSalaries(address account, uint256 amount)public returns(bool){
        require(_owner == msg.sender, "ERROR: You cant Mint Tokens");
        require(account !=address(0),"ERROR:Mintin to zero Address");
        require(_totalSupply + amount <= tokenCap,"ERROR: Reached the token cap");
        
        mintedOn = block.timestamp;
        
        tempArrayofAdd.push(account);
        temporaryStay[account] += amount;
    
        _totalSupply += amount;

        emit Transfer(address(0), account, amount);      
        return true;  
    }

    function transferSalaries()public transferAfterMonth returns(bool){
        for(uint i=0; i <tempArrayofAdd.length; i++){
        balances[tempArrayofAdd[i]] += temporaryStay[tempArrayofAdd[i]];
        }
        return true;
    }
} 
