# blockchain-insurance-smart-contract

## How Does It Work?
- This project contains two Solidity smart contracts
  - customer.sol Smart Contract
  - insuranceContract.sol Smart Contract
 
---
### Insurance Smart Contract
1. Insurance Smart Contract is used to interact with Customer Smart Contract(s).
2. Provides functions to:
   - Approve onboarding of customer
   - Add a new policy
   - Check if a certain policy exists
   - Add customers to be policy holders when a policy is purchased
   - Approve policy purchase request from customers
   - Approve customer's claim request
3. Insurance Smart Contract is initialized to be able to receive and transfer funds when interacting with other Smart Contracts

### Customer Smart Contract
1. Customer Smart Contract is initialized with the address of a specific Insurance Provider's Contract Address.
2. Provides functions to:
   - Request to onboard with insurance provider
   - Request to purchase a certain policy
   - View all available policies
   - View a specific policy's details
   - View the outstanding claims amount
   - File an insurance claim from insurance provider
   - Request claim approval from insurance provider 
