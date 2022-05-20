// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


interface IERC20 {
       
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

//------------------------------------------------------------------



contract Wallet{
  
    address owner;
    mapping(string => Token) public tokenMapping;  
    mapping(address => mapping(string => uint256)) tokenBalances;
    string[] public tokenList;
    modifier onlyOwner{
        require(msg.sender==owner);
        _;
    }
    struct Token{
        string symbol;
        address _contractAddress;
    }


    constructor(address _address){      
        owner = _address;


    }

    function balanceOf(address _address, string memory symbol) public view returns(uint256){
        return tokenBalances[_address][symbol];
    }


    function addToken(string memory symbol, address _contractAddress) external onlyOwner{
        tokenMapping[symbol] = Token(symbol,_contractAddress);
        tokenList.push(symbol);


    } 

    function deposit(uint amount, string memory symbol) external{
        require(tokenMapping[symbol]._contractAddress!=address(0));
        require(IERC20(tokenMapping[symbol]._contractAddress).allowance(msg.sender, address(this))>=amount, "Inscufficient balance");
        IERC20(tokenMapping[symbol]._contractAddress).transferFrom(msg.sender, address(this), amount);
        tokenBalances[msg.sender][symbol]+=amount;
    }

    function withdraw(uint amount, string memory symbol) external{
        require(tokenMapping[symbol]._contractAddress!=address(0));
        require(tokenBalances[msg.sender][symbol]>=amount, "DexWALLET : Insufficient balance");

        tokenBalances[msg.sender][symbol]-=amount;
        IERC20(tokenMapping[symbol]._contractAddress).transfer(msg.sender, amount);
       

    }


}
