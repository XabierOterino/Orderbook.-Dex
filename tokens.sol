pragma solidity ^0.8.0;
import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
//this is a sample token, there should be morein the dex

contract Link is ERC20{
    function deployedBy() public view returns(address){
        return deployer;
    }
    address public deployer;
    constructor() ERC20("Chainlink", "LINK"){
        deployer=msg.sender;
        _mint(msg.sender,10000);
    }

    function thisAddress() public view returns(address){
        return address(this);
    }
}