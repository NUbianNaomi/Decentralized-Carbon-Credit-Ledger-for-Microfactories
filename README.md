# 🌱 Decentralized Carbon Credit Ledger for Microfactories

## 🎯 Overview

A blockchain-based solution that enables microfactories to issue, track, and verify tokenized carbon credits on the Stacks blockchain using Clarity smart contracts. This system democratizes access to carbon markets for small manufacturers while ensuring transparency and preventing greenwashing.

## 🏭 Problem & Solution

**Problem**: Microfactories can't access carbon markets due to lack of verification tools and high barriers to entry.

**Solution**: Decentralized smart contract system that provides:
- 🔐 On-chain verification of carbon credits
- 💰 Direct monetization of sustainability efforts
- 🔍 Transparent tracking and auditing
- 🚀 Low-cost access to carbon markets

## ⚡ Features

- **Factory Registration**: Register microfactories with location and credentials
- **Credit Issuance**: Issue carbon credits with metadata tracking
- **Verification System**: Third-party verifier approval process  
- **Transfer & Trading**: Peer-to-peer credit transfers
- **Credit Retirement**: Permanent retirement for carbon offsetting
- **Integrated Marketplace**: Built-in STX-based trading with price discovery
- **Supply Tracking**: Real-time monitoring of total credit supply

## 🛠️ Contract Functions

### 🏭 Factory Operations
- `register-factory` - Register a new microfactory
- `issue-carbon-credit` - Create new carbon credits
- `deactivate-factory` - Admin function to disable factories

### ✅ Verification Operations  
- `register-verifier` - Register third-party verifiers with address (admin only)
- `verify-carbon-credit` - Approve pending credits
- `reject-carbon-credit` - Reject invalid credits
- `deactivate-verifier` - Admin function to disable verifiers

### 💸 Trading Operations
- `transfer-carbon-credit` - Transfer credits between users
- `retire-carbon-credit` - Permanently retire credits

### 🏪 Marketplace Operations
- `create-marketplace-listing` - List verified credits for sale with STX pricing
- `buy-marketplace-listing` - Purchase credits directly from marketplace
- `cancel-marketplace-listing` - Remove active listings

### 📊 Read-Only Functions
- `get-factory-info` - Factory details and stats
- `get-carbon-credit-info` - Credit details and verification status
- `get-credit-balance` - User balance for specific credit
- `get-verifier-info` - Verifier credentials and status
- `get-total-credits-supply` - Total circulating supply
- `get-marketplace-listing` - Marketplace listing details
- `get-next-listing-id` - Next available listing ID

## 🚀 Quick Start

### Prerequisites
- [Clarinet](https://github.com/hirosystems/clarinet) installed
- Stacks wallet for testing

### Installation
```bash
git clone <repository-url>
cd Decentralized-Carbon-Credit-Ledger-for-Microfactories
clarinet check
```

### Testing
```bash
clarinet test
```

### Deployment
```bash
clarinet deploy --testnet
```

## 📝 Usage Examples

### 1. Register Factory
```clarity
(contract-call? .contract register-factory "GreenTech Micro" "San Francisco, CA")
```

### 2. Issue Carbon Credits  
```clarity
(contract-call? .contract issue-carbon-credit u1000 "Solar panel installation - 1000kg CO2 offset")
```

### 3. Register Verifier (admin only)
```clarity
(contract-call? .contract register-verifier 'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7 "CarbonAudit Inc" "ISO 14001 Certified")
```

### 4. Verify Credits (as verifier)
```clarity
(contract-call? .contract verify-carbon-credit u1)
```

### 5. Transfer Credits
```clarity
(contract-call? .contract transfer-carbon-credit u1 u500 'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7)
```

### 6. Create Marketplace Listing
```clarity
(contract-call? .contract create-marketplace-listing u1 u500 u1000000)
```

### 7. Buy from Marketplace
```clarity
(contract-call? .contract buy-marketplace-listing u1)
```

### 8. Retire Credits
```clarity
(contract-call? .contract retire-carbon-credit u1 u250)
```

## 🔍 Error Codes

- `u100` - Owner only operation
- `u101` - Not authorized  
- `u102` - Insufficient balance
- `u103` - Invalid amount
- `u104` - Factory not registered
- `u105` - Credit not found
- `u106` - Already verified
- `u107` - Not verified
- `u108` - Factory already registered
- `u109` - Verifier already registered
- `u110` - Listing not found
- `u111` - Insufficient payment
- `u112` - Listing already exists
- `u113` - Cannot buy own listing

## 🌟 Benefits

- **🎯 Accessible**: Low barriers for microfactory participation
- **🔒 Secure**: Blockchain-based immutable records  
- **👀 Transparent**: Public verification and audit trails
- **💡 Efficient**: Automated verification and transfer processes
- **🌍 Impactful**: Incentivizes real sustainability efforts

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## 📄 License

This project is licensed under the MIT License.

## 🔗 Links

- [Stacks Documentation](https://docs.stacks.co/)
- [Clarity Language Reference](https://docs.stacks.co/clarity/)
- [Clarinet Documentation](https://github.com/hirosystems/clarinet)

---

*Built with 💚 for a sustainable future*
