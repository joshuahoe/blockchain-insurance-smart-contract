// SPDX-License_Identifier: MIT
pragma solidity ^0.8.0;
contract Insurance {
    address payable insuranceAddress; // address variable that holds the address of this contract
    address[] private policyholders; // array to hold the address of customers who purchase a policy
    address[] private customers; // array to hold the address of customers who onboard with this insurance provider
    mapping(address => uint256[]) private customerPolicies; // a mapping of customer addresses to an array of policies they have
    mapping(address => uint256) private outstandingClaims; // a mapping of customer addresses to the amount of claims that are outstanding
    mapping(uint256 => availablePolicy) private availablePolicies; // a mapping of a policy's id to its policy details
    uint256[] private availablePoliciesIdArray; // an array to hold the ids of policies added by the insurance provider
    event Received(address, uint); // an event to be emitted when any funds is received by this contract

    // a struct defined to store an available policy's details
    struct availablePolicy {
        string description;
        uint256 policyPremium;
        uint256 payoutAmount;
    }

    // receive() function to allow funds to be received
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    // contract constructor
    constructor() payable {
        insuranceAddress = payable(msg.sender);
    }

    // function to allow insurance provider to add policies to make it available to be purchased
    function addPolicyToAvailablePolicies(uint _policyId, uint256 _policyPremium, uint256 _payoutAmount, string memory _description) public {
        require(checkPolicyAvailable(_policyId) == false, "Policy with same ID already exists");
        availablePolicies[_policyId] = availablePolicy(_description, _policyPremium, _payoutAmount);
        availablePoliciesIdArray.push(_policyId);
    }

    // function to handle customer request to purchase a policy
    // it checks whether customer has already onboarded before approving request
    function approvePurchasePolicyRequest(uint256 policyId, address customerAddress) public payable returns (bool) {
        bool approved = false;
        for (uint i = 0; i < customers.length; i++) {
            if (customers[i] == customerAddress) {
                approved = true;
            }
        }
        if (approved) {
            addToPolicyHolders(customerAddress); //adds customer's addres to PolicyHolders array
            customerPolicies[customerAddress].push(policyId); // adds policy id to the address of customer
        }

        return approved;
        
    }

    // function to handle customer request to onboard
    // checks if customer has already onboarded
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

    // get function to return an array of customer's policies(id) given their address
    function getCustomerPolicies(address policyHolder) public view returns (uint256[] memory) {
        return customerPolicies[policyHolder];
    }

    // get function to return the premium of a policy given the policyId
    function getPolicyPremium(uint256 policyId) public view returns (uint256) {
        return availablePolicies[policyId].policyPremium;
    }

    // get function to return the payout amount of a policy given the policyId
    function getPolicyPayoutAmount(uint256 policyId) public view returns (uint256) {
        return availablePolicies[policyId].payoutAmount;
    }

    // get function that returns the total premium the customer has paid given customer address
    function getTotalPremium(address customerAddress) public view returns (uint256) {
        uint256 totalPremium = 0;
        for (uint256 i = 0; i < customerPolicies[customerAddress].length; i++) {
            totalPremium += getPolicyPremium(customerPolicies[customerAddress][i]);
        }
        return totalPremium;
    }

    // function to add a customer's address to policyholders array
    // checks if customer is already in policyholders array
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

    //get function to return an array of ids of all available policies
    function getAllAvailablePoliciesId() public view returns (uint256[] memory) {
        return availablePoliciesIdArray;
    }

    // get function to return availablePolicy struct given policyId
    function getAvailablePolicyById(uint256 policyId) public view returns (availablePolicy memory) {
        require(availablePoliciesIdArray.length != 0, "No policies available yet!");
        require(checkPolicyAvailable(policyId), "No such policy available!");
        return availablePolicies[policyId];
    }

    // function to check if a policy is available given its id
    function checkPolicyAvailable(uint256 policyId) public view returns (bool) {
        bool policyPresent = false;
        for (uint256 i = 0; i < availablePoliciesIdArray.length; i++) {
            if (availablePoliciesIdArray[i] == policyId) {
                policyPresent = true;
            }
        }

        return policyPresent;
    }

    // function to add claim amount to outstandingClaims 
    function addToOutstandingClaims(uint256 claimAmount, address customerAddress) public {
        outstandingClaims[customerAddress] += claimAmount;
    }

    // function to handle customer's request to approve a claim
    // checks if a customer is a policyholder first
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

    // function to approve customer claim and transfer claim amount to customer contract 
    function approveClaim(address payable customerAddress, uint256 claimAmount) public payable {
        customerAddress.transfer(claimAmount);
        outstandingClaims[customerAddress] -= claimAmount;

    }

    // get function to return a customer's outstanding claim amount given the customer's address
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
