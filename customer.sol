// SPDX-License_Identifier: MIT
pragma solidity ^0.8.0;

import "./insurance.sol"; 

contract Customer {
    address public insuranceProvider;
    address payable customerAddress;
    mapping(address => uint256) public policies;
    mapping(address => uint256) public claims;
    mapping(uint256 => uint256) public customersPolicies; //policyId => policyPremium
    
    

    constructor(address _insuranceProvider) {
        insuranceProvider = _insuranceProvider;
        customerAddress = payable(msg.sender);
    }


    function purchasePolicy(uint256 policyId) public payable {
        require(customersPolicies[policyId] == 0, "Customer has already purchased this policy");
        uint256 premium = Insurance(insuranceProvider).getPolicyPremium(policyId);
        require(msg.value >= premium, "Insufficient balance to purchase policy");
        Insurance(insuranceProvider).sellPolicy(policyId, customerAddress);
        require(payable(insuranceProvider).send(premium), "Payment to insurance contract failed");
    }


    // function fileClaim(uint256 amount) public {
    //     require(policies[msg.sender] > 0, "must have a valid policy to file a claim");
    //     require(amount > 0, "Claim amount  must be greater than 0.");
    //     require(amount <= policies[msg.sender], "Claim amount cannot exceed policy");
    //     claims[msg.sender] += amount;


    // }   




}