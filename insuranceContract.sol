// SPDX-License_Identifier: MIT
pragma solidity ^0.8.0;
contract Insurance {
    address[] public policyholders;
    mapping(address => uint256[]) public customerPolicies;
    mapping(address => uint256) public claims;
    mapping(uint256 => availablePolicy) public availablePolicies;
    address payable insuranceAddress;

    struct availablePolicy {
        uint256 policyAmount;
        uint256 policyPremium;
    }


    constructor() {
        insuranceAddress = payable(msg.sender);
    }

    function addPolicyToAvailablePolicies(uint _policyId, uint256 _policyPremium, uint256 _payoutAmount) public {
        availablePolicies[_policyId] = availablePolicy(_policyPremium, _payoutAmount);
    } 

    function sellPolicy(uint256 policyId, address customerAddress) public payable {
        customerPolicies[customerAddress].push(policyId);
    }

    // function approveClaim(address policyholder) public payable {
    //     require(msg.sender == insuranceAddress, "only the owner can approve claims.");
    //     require(claims[policyholder] > 0, "policyholder has no outstanding claims");
    //     payable (policyholder).transfer(claims[policyholder]);
    //     claims[policyholder] = 0;

    // }

    function getCustomerPolicies(address policyHolder) public view returns (uint256[] memory) {
        return customerPolicies[policyHolder];

    }

    // function getClaim(address policyHolder) public view returns (uint256) {
    //     return claims[policyHolder];
    // }


    function getPolicyPremium(uint256 policyId) public view returns (uint256) {
        return availablePolicies[policyId].policyPremium;
    }

    function getTotalPremium(address customerAddress) public view returns (uint256) {
        uint256 totalPremium = 0;
        for (uint256 i = 0; i < customerPolicies[customerAddress].length; i++) {
            totalPremium += getPolicyPremium(customerPolicies[customerAddress][i]);
        }
        return totalPremium;
    }

    // function grantAccess(address payable user) public {
    //     require(msg.sender == owner, "only the owner can grant access");
    //     owner = user;
    // }   

    // function revokeAccess(address payable user) public {
       
       
    //     require(msg.sender == owner, "only owner ccan revoke access");
    //     require(user != owner, "cannot revoke access for current owner");
    //     owner = payable(msg.sender);


    // }


}