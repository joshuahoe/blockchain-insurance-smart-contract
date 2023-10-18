// SPDX-License_Identifier: MIT
pragma solidity ^0.8.0;
contract Insurance {
    address[] public policyholders;
    mapping(address => uint256) public policies;
    mapping(address => uint256) public claims;
    mapping(uint256 => uint256) public availablePolicies;
    address payable owner;
    uint256 public totalPremium;

    struct availablePolicy {
        uint policyId;
        uint256 policyPremium;
    }
    // availablePolicy[] public availablePolicies;

    constructor() {
        owner = payable(msg.sender);
    }

    function addPolicyToAvailablePolicies(uint _policyId, uint256 _policyPremium) public {
        availablePolicies[_policyId] = _policyPremium;
    }

    function purchasePolicy(uint256 policyId) public payable {
        uint256 premium = availablePolicies[policyId];
        // require(premium == getPolicyPremium(policyId), "incorrect policy amount");
        require(premium > 0, "premium amount must be greater than 0.");
        policyholders.push(msg.sender);
        policies[msg.sender] = premium;
        totalPremium += premium;

    }


    function fileClaim(uint256 amount) public {
        require(policies[msg.sender] > 0, "must have a valid policy to file a claim");
        require(amount > 0, "Claim amount  must be greater than 0.");
        require(amount <= policies[msg.sender], "Claim amount cannot exceed policy");
        claims[msg.sender] += amount;


    }   

    function approveClaim(address policyholder) public payable {
        require(msg.sender == owner, "only the owner can approve claims.");
        require(claims[policyholder]> 0, "policyholder has no outstanding claims");
        payable (policyholder).transfer(claims[policyholder]);
        claims[policyholder] = 0;

    }

    function getPolicy(address policyholder) public view returns (uint256) {
        return policies[policyholder];

    }

    function getClaim(address policyholder) public view returns (uint256) {
        return claims[policyholder];
    }

    function getTotalPremium() public view returns (uint256) {
        return totalPremium;
    }

    function getPolicyPremium(uint256 policyId) public view returns (uint256) {
        return availablePolicies[policyId];
    }

    function grantAccess(address payable user) public {
        require(msg.sender == owner, "only the owner can grant access");
        owner = user;
    }   

    function revokeAccess(address payable user) public {
       
       
        require(msg.sender == owner, "only owner ccan revoke access");
        require(user != owner, "cannot revoke access for current owner");
        owner = payable(msg.sender);


    }


}
