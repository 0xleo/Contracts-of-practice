// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.7.0 <0.9.0;

contract authAddress {

    mapping(address => bool) public users; //in the mapping address type... 
    //... key the addresses that have been authenticated are stored, ...
    //... the bool value will tell us if that address is authenticated

    function authenticate() public { //when the user calls this function...
    //... his address will be registered in the mapping as authenticated address
        users[msg.sender] = true;
    }

    modifier userAuth() { //this modifier is added to the contract functions...
    //... that you want to be called only if the calling address is authenticated
        require( true == users[msg.sender], "You are not authenticated" );_;        
    }
   
__________________________________________________________________________________
    
    
     //This is another way to do it, the difference is that the address...
     //... that calls the function is not the one that is authenticated, ...
     //... but the address that is introduced by the parameter is the one that is authenticated
     
     mapping(address => address) public users;

    function authenticate(address contractAddress) public {
        users[msg.sender] = contractAddress;
    }
