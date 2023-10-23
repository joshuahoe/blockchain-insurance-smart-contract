// SPDX-License_Identifier: MIT
pragma solidity ^0.8.0;

import "./insurance.sol"; 

contract Customer {
    address payable insuranceProviderAddress;
    address payable customerAddress;
    mapping(address => uint256) public claims;
    mapping(uint256 => uint256) public customersPolicies; //policyId => policyPremium
    event Received(address, uint);
    
    

    constructor(address payable _insuranceProvider) payable {
        insuranceProviderAddress = payable(_insuranceProvider);
        customerAddress = payable(address(this));
    }

     receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    function purchasePolicy(uint256 policyId) public payable {
        uint256[] memory lstOfCustomerPolicies = Insurance(insuranceProviderAddress).getCustomerPolicies(customerAddress);
        if (lstOfCustomerPolicies.length != 0) {
            for (uint256 i = 0; i < lstOfCustomerPolicies.length; i++) {
                require(lstOfCustomerPolicies[i] != policyId, "Customer has already purchased this policy");
            }
        }
        uint256 premium = Insurance(insuranceProviderAddress).getPolicyPremium(policyId);
        require(msg.value >= premium, "Insufficient balance to purchase policy");
        Insurance(insuranceProviderAddress).sellPolicy(policyId, customerAddress);
        insuranceProviderAddress.transfer(premium);
    }


    // function fileClaim(uint256 amount) public {
    //     require(insurancePolicies[msg.sender] > 0, "must have a valid policy to file a claim");
    //     require(amount > 0, "Claim amount  must be greater than 0.");
    //     claims[msg.sender] += amount;


    // }   




}