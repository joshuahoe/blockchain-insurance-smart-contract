// SPDX-License_Identifier: MIT
pragma solidity ^0.8.0;

import "./insurance.sol"; 

contract Customer {
    address payable insuranceProviderAddress; // address of insurance provider that the customer is interacting with
    address payable customerAddress; // address of customer's own contract
    event Received(address, uint); // an event to be emitted when any funds is received by this contract

    // customer contract's constructor, takes in insurance provider's contract address
    constructor(address payable _insuranceProvider) payable {
        insuranceProviderAddress = payable(_insuranceProvider);
        customerAddress = payable(address(this));
    }

    // receive() function to allow funds to be received
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    // function for customer to request to purchase a policy
    // checks if the policy is available to be purchased, check that the customer has not already purchased this policy
    // checks that customer has enough funds to purchase this policy
    // checks if customer is onboarded first
    function requestToPurchasePolicy(uint256 policyId) public payable {
        bool policyPresent = Insurance(insuranceProviderAddress).checkPolicyAvailable(policyId);
        require(policyPresent, "This policy is not available to be purchased!");
        uint256[] memory lstOfCustomerPolicies = Insurance(insuranceProviderAddress).getCustomerPolicies(customerAddress);
        if (lstOfCustomerPolicies.length != 0) {
            for (uint256 i = 0; i < lstOfCustomerPolicies.length; i++) {
                require(lstOfCustomerPolicies[i] != policyId, "Customer has already purchased this policy");
            }
        }
        uint256 premium = Insurance(insuranceProviderAddress).getPolicyPremium(policyId);
        require(msg.value >= premium, "Insufficient balance to purchase policy");
        require(Insurance(insuranceProviderAddress).approvePurchasePolicyRequest(policyId, customerAddress), "Customer have to onboard first");
        insuranceProviderAddress.transfer(premium);
    }

    // function for customer to onboard with insurance provider
    function requestOnboard() public {
        Insurance(insuranceProviderAddress).approveCustomerOnboard();
    }

    // function for customer to view all policyId of policies that are available to be purchased
    function viewAvailablePolicies() public view returns (uint256[] memory) {
        return Insurance(insuranceProviderAddress).getAllAvailablePoliciesId();
    }

    // function to return the policy details given a policyId
    function viewPolicyDetails(uint256 policyId) public view returns (Insurance.availablePolicy memory) {
        return Insurance(insuranceProviderAddress).getAvailablePolicyById(policyId); 
    }

    // function for customers to view its outstanding claims
    function viewOutstandingClaims(address policyHolder) public view returns (uint256) {
        return Insurance(insuranceProviderAddress).getOutstandingClaims(policyHolder);
    }

    // function to file a claim from insurance provider
    // checks that customer has ongoing policy and that customer is claiming from a policy he/she has purchased
    // checks that claim amount does not exceed policy's payout amount
    function fileClaim(uint256 amount, uint256 policyId) public {
        bool present = false;
        uint256[] memory lstOfCustomerPolicies = Insurance(insuranceProviderAddress).getCustomerPolicies(customerAddress);
        require(lstOfCustomerPolicies.length > 0, "Customer does not have any policies to claim");
        for (uint i = 0; i < lstOfCustomerPolicies.length; i++) {
            if (lstOfCustomerPolicies[i] == policyId) {
                present = true;
            }
        }
        require(present, "Customer does not have this policy purchased");
        uint256 payoutAmount = Insurance(insuranceProviderAddress).getPolicyPayoutAmount(policyId);
        require(amount <= payoutAmount, "Claim amount must be smaller than or equal to policy's payout amount.");
        Insurance(insuranceProviderAddress).addToOutstandingClaims(amount, customerAddress);
    }   

    // function for customer to request claim approval after filing for a claim
    // checks that the clam amount does not exceed the outstanding claims and is greater than 0
    function requestClaimApproval(uint256 amount) public {
        uint256 outstandingClaims = Insurance(insuranceProviderAddress).getOutstandingClaims(customerAddress);
        require(amount > 0, "Claim amount must be more than 0");
        require(amount <= outstandingClaims, "Cannot request for claim more than oustanding claim amount.");
        Insurance(insuranceProviderAddress).handleApproveClaim(customerAddress, amount);
    }




}
