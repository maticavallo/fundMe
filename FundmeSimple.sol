// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// @title FundMe
// @ dev The contract allows users to fund an address.

// @dev Error for when the msg.sender is not the contract owner
error NotOwner();

contract FundMe {
    // @dev Mapping to store the amount of funds each address has sent
    mapping(address => uint256) public addressToAmountFunded;

    //@dev Array to store the addresses of all the funders
    address[] public funders;

    // @dev Public variable to store the address of the contract owner
    address public owner;

    // @dev Public constant to set the minimum amount in USD that must be sent to the contract
    uint256 public constant minimumContribution = 0.01 * 1e17;

    //@dev Constructor function that runs when the contract is deployed and sets the owner as the msg.sender
    constructor() {
        owner = msg.sender;
    }
    
    // @dev Allows users to send Ether to the contract and adds it to the mapping and array of funders
    // @param _value The amount of Ether to send to the contract
    function fund() public payable {
        // Check that the value of the Ether sent is greater than or equal to the minimunContribution
        require(msg.value >= minimumContribution, "You need to send at least 0.1 ETH");
        // Add the sender's address and the amount sent to the mapping
        addressToAmountFunded[msg.sender] += msg.value;
        // Add the sender's address to the array of funders
        funders.push(msg.sender);
}
    // @dev Allows the contract owner to withdraw all funds stored in the contract
    function withdraw() public onlyOwner {
        // loop through the funders array
        for (uint256 funderIndex=0; funderIndex < funders.length; funderIndex++){
        // Get the address of the current funder
            address funder = funders[funderIndex];
        // Reset the amount of funds each funder has sent
            addressToAmountFunded[funder] = 0;
        }
        
        // Clear the array of funders
        funders = new address [](0);

        // Send all the funds stored in the contract to the contract owner
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    // @dev Allows users to send Ether to the contract using the fallback function
    fallback() external payable {
        // Calls the fund() function
        fund();
    }

    // @dev Allows users to send Ether to the contract using the `receive()` function
    receive() external payable {
        // Calls the fund() function
        fund();
}

    // @dev Modifier that allows only the contract owner to call a function
    modifier onlyOwner {
        // Check if the msg.sender is not the contract owner
        if (msg.sender != owner) revert NotOwner();
        _;
}
}