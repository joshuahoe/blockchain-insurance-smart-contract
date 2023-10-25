// SPDX-License_Identifier: MIT
pragma solidity ^0.8.0;

import "./insurance.sol"; 

contract Customer {
    address payable insuranceProviderAddress;
    address payable customerAddress;
    mapping(uint256 => uint256) public customersPolicies; //policyId => policyPremium
    event Received(address, uint);

    constructor(address payable _insuranceProvider) payable {
        insuranceProviderAddress = payable(_insuranceProvider);
        customerAddress = payable(address(this));
    }

     receive() external payable {
        emit Received(msg.sender, msg.value);
    }

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

    function requestOnboard() public {
        Insurance(insuranceProviderAddress).approveCustomerOnboard();
    }

    function viewAvailablePolicies() public view returns (uint256[] memory) {
        return Insurance(insuranceProviderAddress).getAllAvailablePoliciesId();
    }

    function viewPolicyDetails(uint256 policyId) public view returns (Insurance.availablePolicy memory) {
        return Insurance(insuranceProviderAddress).getAvailablePolicyById(policyId); 
    }

    function viewOutstandingClaims(address policyHolder) public view returns (uint256) {
        return Insurance(insuranceProviderAddress).getOutstandingClaims(policyHolder);
    }


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

    function requestClaimApproval(uint256 amount) public {
        uint256 outstandingClaims = Insurance(insuranceProviderAddress).getOutstandingClaims(customerAddress);
        require(amount > 0, "Claim amount must be more than 0");
        require(amount <= outstandingClaims, "Cannot request for claim more than oustanding claim amount.");
        Insurance(insuranceProviderAddress).handleApproveClaim(customerAddress, amount);
    }




}
