# IS452-blockchain-insurance-smart-contract

## What does this do?
- This project contains two Solidity smart contracts
  - `customer.sol` Smart Contract
  - `insuranceContract.sol` Smart Contract
  
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
3. Customer Smart Contract is initialized to be able to receive and transfer funds when interacting with other Smart Contracts
--- 

## How to run the Smart Contracts? 
1. Save both smart contract files.
2. Visit [Remix](remix.ethereum.org)
3. Navigate to Solidity Compiler using the side navigation bar
4. Compile `insuranceContract.sol` and deploy it with 1 ETH
5. Copy the Contract Address of the deployed insurance smart contract
6. Compile `customer.sol` and deploy it with 1 ETH along with the CA from step 5
7. Start calling functions to watch how both contracts interact with each other.
8. Have fun!
