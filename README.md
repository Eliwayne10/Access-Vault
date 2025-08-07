# Access-Vault Smart Contract

A decentralized access management system built on Stacks blockchain that enables content providers to monetize digital assets through controlled access mechanisms.

## Overview

Access-Vault is a smart contract that allows content creators to:
- Register digital assets with customizable pricing
- Manage access rights through STX payments
- Track access permissions on-chain
- Enable/disable assets as needed

## Features

- **Asset Registration**: Content providers can register digital assets with metadata
- **Access Control**: Users can purchase access rights using STX tokens
- **Permission Tracking**: On-chain logging of access rights
- **Provider Controls**: Asset owners can manage asset availability
- **Event Tracking**: Emits events for access grants and management actions

## Contract Functions

### Public Functions

```clarity
(register-asset (title (string-ascii 50)) (desc (string-ascii 100)) (price uint) (uri (string-ascii 100)))
```
Registers a new digital asset with title, description, price, and content URI.

```clarity
(buy-access (id uint))
```
Purchases access rights to an asset by its ID.

```clarity
(disable-asset (id uint))
```
Allows the provider to disable access to their asset.

### Read-Only Functions

```clarity
(get-asset (id uint))
```
Retrieves asset details by ID.

```clarity
(has-access (id uint) (user principal))
```
Checks if a user has access to a specific asset.

## Data Storage

- `data-assets`: Maps asset IDs to their metadata and access controls
- `access-log`: Tracks user access rights and purchase history
- `event-counter`: Maintains sequential event tracking

## Error Codes

- `ERR_NOT_FOUND (u404)`: Asset not found
- `ERR_UNAUTHORIZED (u401)`: Unauthorized access attempt
- `ERR_INACTIVE (u403)`: Asset is not active
- `ERR_INSUFFICIENT_FUNDS (u402)`: Insufficient STX balance
- `ERR_BLOCK_INFO (u500)`: Block information error

## Development

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet)
- [Stacks CLI](https://docs.stacks.co/references/stacks-cli)

### Testing

```bash
clarinet test
```

### Deployment

1. Configure your network settings in `Clarinet.toml`
2. Deploy using Clarinet:
```bash
clarinet deploy
```


4. Push to the branch
5. Open a Pull Request
