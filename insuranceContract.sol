// SPDX-License_Identifier: MIT
pragma solidity ^0.8.0;
contract Insurance {
    address[] public policyholders;
    address[] public customers;
    address payable insuranceAddress;
    mapping(address => uint256[]) public customerPolicies;
    mapping(address => uint256) public outstandingClaims;
    mapping(uint256 => availablePolicy) public availablePolicies;
    uint256[] public availablePoliciesIdArray;
    event Received(address, uint);

    struct availablePolicy {
        string description;
        uint256 policyPremium;
        uint256 payoutAmount;
    }

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    constructor() payable {
        insuranceAddress = payable(msg.sender);
    }

    function addPolicyToAvailablePolicies(uint _policyId, uint256 _policyPremium, uint256 _payoutAmount, string memory _description) public {
        require(checkPolicyAvailable(_policyId) == false, "Policy with same ID already exists");
        availablePolicies[_policyId] = availablePolicy(_description, _policyPremium, _payoutAmount);
        availablePoliciesIdArray.push(_policyId);
    }

    function approvePurchasePolicyRequest(uint256 policyId, address customerAddress) public payable returns (bool) {
        bool approved = false;
        for (uint i = 0; i < customers.length; i++) {
            if (customers[i] == customerAddress) {
                approved = true;
            }
        }
        if (approved) {
            addToPolicyHolders(customerAddress);
            customerPolicies[customerAddress].push(policyId);
        }

        return approved;
        
    }

    function approveCustomerOnboard() public {
        bool customerOnboarded = false;
        for (uint i = 0; i < customers.length; i++) {
            if (customers[i] == msg.sender) {
                customerOnboarded = true;
            }
        }
        require(!customerOnboarded, "Customer already onboarded!");
        customers.push(msg.sender);
    }

    function getCustomerPolicies(address policyHolder) public view returns (uint256[] memory) {
        return customerPolicies[policyHolder];
    }

    function getPolicyPremium(uint256 policyId) public view returns (uint256) {
        return availablePolicies[policyId].policyPremium;
    }

    function getPolicyPayoutAmount(uint256 policyId) public view returns (uint256) {
        return availablePolicies[policyId].payoutAmount;
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
        require(availablePoliciesIdArray.length != 0, "No policies available yet!");
        require(checkPolicyAvailable(policyId), "No such policy available!");
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

    function addToOutstandingClaims(uint256 claimAmount, address customerAddress) public {
        outstandingClaims[customerAddress] += claimAmount;
    }

    function handleApproveClaim(address payable customerAddress, uint256 claimAmount) public payable {
        bool customerIsPolicyHolder = false;
        for (uint i = 0; i < policyholders.length; i++) {
            if (policyholders[i] == customerAddress) {
                customerIsPolicyHolder = true;
            }
        }

        require(customerIsPolicyHolder, "Customer cannot make claim if not policy holder!");
        approveClaim(customerAddress, claimAmount);
    }

    function approveClaim(address payable customerAddress, uint256 claimAmount) public payable {
        customerAddress.transfer(claimAmount);
        outstandingClaims[customerAddress] -= claimAmount;

    }

    function getOutstandingClaims(address customerAddress) public view returns (uint256) {
        return outstandingClaims[customerAddress];
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
