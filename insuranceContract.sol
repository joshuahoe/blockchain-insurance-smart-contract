// SPDX-License_Identifier: MIT
pragma solidity ^0.8.0;
contract Insurance {
    address[] public policyholders;
    address payable insuranceAddress;
    mapping(address => uint256[]) public customerPolicies;
    mapping(address => uint256) public claims;
    mapping(uint256 => availablePolicy) public availablePolicies;
    event Received(address, uint);
    uint256[] public availablePoliciesIdArray;

    struct availablePolicy {
        uint256 policyPremium;
        uint256 payoutAmount;
    }

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    constructor() payable {
        insuranceAddress = payable(msg.sender);
    }

    function addPolicyToAvailablePolicies(uint _policyId, uint256 _policyPremium, uint256 _payoutAmount) public {
        require(checkPolicyAvailable(_policyId) == false, "Policy with same ID already exists");
        availablePolicies[_policyId] = availablePolicy(_policyPremium, _payoutAmount);
        availablePoliciesIdArray.push(_policyId);
    }

    function sellPolicy(uint256 policyId, address customerAddress) public payable {
        addToPolicyHolders(customerAddress);
        customerPolicies[customerAddress].push(policyId);
    }

    function getCustomerPolicies(address policyHolder) public view returns (uint256[] memory) {
        return customerPolicies[policyHolder];
    }

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

    function addToPolicyHolders(address customerAddress) public {
        bool present = false;
        for (uint i = 0; i < policyholders.length; i++) {
            if (policyholders[i] == customerAddress) {
                present = true;
            }
        }

        if (!present) {
            policyholders.push(customerAddress);
        }
    }

    //get all available policies
    function getAllAvailablePoliciesId() public view returns (uint256[] memory) {
        return availablePoliciesIdArray;
    }

    function getAvailablePolicyById(uint256 policyId) public view returns (availablePolicy memory) {
        require(availablePoliciesIdArray.length != 0, "No policies available");
        return availablePolicies[policyId];
    }

    function checkPolicyAvailable(uint256 policyId) public view returns (bool) {
        bool policyPresent = false;
        for (uint256 i = 0; i < availablePoliciesIdArray.length; i++) {
            if (availablePoliciesIdArray[i] == policyId) {
                policyPresent = true;
            }
        }

        return policyPresent;
    }

    // function getClaim(address policyHolder) public view returns (uint256) {
    //     return claims[policyHolder];
    // }

    // function approveClaim(address policyholder) public payable {
    //     require(msg.sender == insuranceAddress, "only the owner can approve claims.");
    //     require(claims[policyholder] > 0, "policyholder has no outstanding claims");
    //     payable (policyholder).transfer(claims[policyholder]);
    //     claims[policyholder] = 0;

    // }

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
