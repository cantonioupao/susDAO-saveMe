pragma solidity ^0.5.16;

import 'contracts/tokens/ERC20Plus.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';
//import 'DataAccess.sol';



/*This Contract creates a SaveMe token . The parameters that need to be aprsed are the amount of token supply , the owner and the token creator*/



contract SaveMeToken is  ERC20Plus {

    using SafeMath for uint256;
    using SafeMath for uint8; //use safemath for all math operations to avoid overflows and hacking of your smart contracts
    string public token_name = "SaveMe";
    string  public token_symbol = "SVM";
    string  public standard = "SaveMe v1.0";
    string public description = "SaveMe is a Token for Health. It aims to award patients of diabetes around the world, for self-catering and engagement to retain stable blood glucose levels throughout the day";
    uint public tokenCreationTime;
    address public tokenCreator;
    uint initialSupply; //others can access as well
    address initialSupplyOwner; //others can access as well
    bool public  isBurnable = true ;
    bool public isTransferable = true ;
    bool public isMintable = true ;
    uint8 public token_decimals = 0 ; //we don't want our token to be divisable
    uint256 public token_totalSupply;
    
    mapping(address =>uint256) private balances;
    mapping(address =>mapping(address => uint256)) private allowances;
    mapping (address=> bool) private minters;
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _value);

    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    event MinterRemoved(
        address indexed account
        );

    event MinterAdded(
        address indexed account
        );
    //call an instance of the token and parse in the initial supply, the owner and the token creator address


    constructor(uint _initialSupply)
        ERC20Plus( token_name, token_symbol, token_decimals, address(0),
        isBurnable, isTransferable, isMintable, _initialSupply, address(0)) //_initialSupplyOwner)
        public {
        tokenCreator = msg.sender;//_tokenCreator;
        initialSupply = _initialSupply;
        initialSupplyOwner = address(0);
        token_totalSupply = initialSupply;
    }

     function transfer(address _to, uint256 _value) public returns (bool success) {  //method deploying contract and sending tokens
        require(balanceOf(msg.sender) >= _value, "Not enough tokens");
        balances[msg.sender] -= _value;
        balances[_to] += _value;

        emit Transfer(msg.sender, _to, _value);

        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) { //give approval to an account to withdraw from another account
        require(balanceOf(msg.sender) >= _value, "Not enough tokens"); //ensure that the user has enough tokens
        allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);

        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) { //transfer from one account to another
        require(_value <= balanceOf(_from), "Not enough tokens to transfer required amount");
        require(_value <= allowances[_from][msg.sender], "You earned all the agreed tokens, cannot get more");

        balances[_from] -= _value; //remove from other account address
        balances[_to] += _value;  //add to one account address

        allowances[_from][msg.sender] -= _value; //reduce amount of allowance by 1 everytime

        emit Transfer(_from, _to, _value); //trigger even for token transfer

        return true;
    }



    function getTokenInfo(address user) public view returns( string memory, string memory,
        string memory, uint256, uint) {
        return (name(), symbol(), description, totalSupply(),tokenCreationTime);
    }

    function getDetailedTokenInfo() public view returns(uint256, uint256, uint,
        bool[] memory, uint[] memory) {

        bool[] memory props = new bool[](4);
        props[0] = isTransferable;
        props[1] = isMintable;
        props[2] = isBurnable;
        props[3] = false; // isCapped

        uint[] memory values = new uint[](3);
        values[0] = 0; // cap
        values[1] = uint(decimals());
        values[2] = initialSupply;

        return (balanceOf(msg.sender), totalSupply(), tokenCreationTime, props, values);
    }

    function totalSupply() public view returns (uint _totalSupply){
        _totalSupply = token_totalSupply;
    }

    function balanceOf(address _of) public view returns  (uint _balance){
        return balances[_of];
    }

    function name() public view returns(string memory){
            return token_name;
        }
    function symbol() public view returns(string memory){
            return token_symbol;
    }


    function giveDataAccess( address _from , address _to) public returns (bool success) {
        //Deploy contract
        /* require(msg.sender == _to); //we want the one who pays for the contract to be the one asking for access
        DataAccess instance = DataAccess(_to );
        bool grantedAccess =  instance.giveAccess(_from , _to);
        if (grantedAccess =true ){
           return true;
        }
        */
        return false ;

    }

    function validateTokens( address _from, address _to ) public returns (bool success){
        require (msg.sender == _from) ; // require the one paying for the contract to be the one paying the tokens
        /*TokenValidation instance = TokenValidation(_from );
        instance.deployTokens(_from,_to);
        */
        return true;
    }

    // Mint new tokens.
    // It accepts only an address with Minter Role => Token Validation Contract

    //function isMinter(address account) public view returns (bool);= //Checks if a specific address has Minter Role

    //function addMinter(address account) public;//Add an address as a Minter with Minter Role rights

    //function renounceMinter() public;//only the address that has Minter roles can renounce itself from its role

}
