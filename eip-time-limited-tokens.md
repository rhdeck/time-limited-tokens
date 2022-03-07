---
eip: <to be assigned>
title: Time-Limited Tokens
description: Expressing and transferring leases to deeds
author: Naiyoma Aurelia ([@naiyoma](https://github.com/naiyoma)), Ray Deck ([@rhdeck](https://github.com/rhdeck)), Akshay Rakheja ([@akshay-rakheja](https://github.com/akshay-rakheja)), Robert Reinhart ([@robertreinhart](https://github.com/robertreinhart)) and Radek Sienkiewicz ([@sabon](https://github.com/sabon))
discussions-to: https://github.com/rhdeck/time-limited-tokens/issues
status: Draft
type: Standards
category (*only required for Standards Track): ERC
created: 2022-03-06
requires: 165
---

## Simple Summary

This standard describes a simple, supple interface for expressing and transferringtime-limited rights or obligations, also known as leases. 

## Motivation
Time is the ultimate scarce resource. We have less of it every second. Time slicing is critical to ideas of fractional possession - allocating rights for a finite period allows resources to generate more value for more humans without requiring their growth or change.

The surging popularity of ERC721 tokens shows the opportunity for clear, simple standards for allocating property rights on the blockchain. Critical to any idea of property rights is the ability to lend or lease an asset for a limited period of time. Blockchain has a unique opportunity to permit these transactions without trust or a third party guarantor because of the public, immutable record. 

However, ERC721 and related standards do not provide functionality to enable leasing of NFTs or other assets for a specific period. 

Allocating time-based rights in a standard that lets people know who possesses a given asset, as separate from ultimate ownership. The question is who has possession at a specific point in time. For example, the tenant/occupant of a flat can change between months or years, while ownership is indefinite. This standard looks at the question of allocating those rights, who one can allocate them from (e.g. subletting), and looking into the future to understand who will have those rights for making future use case decisions.

## Use Cases

### Electronic Apartment Lock - "Web3-n-B"

People lease apartments from property owners. Sometimes, we want to re-lease access to that apartment to a third party, a la as an AirBnB host. We want to give access to the apartment to the sub-letter for a specific period of time, and the sub-letter should expect that they will have privacy, e.g. the original tenant does not intrude during this period. The tenant has a lease from the property owner that might last a year. The goal is to tell the apartment lock to allow that tenant access during their term, and to transfer that access to the subletter during their (shorter) stay. A blockchain-powered lock could grant access based on who has the rights to that apartment at that point in time. The contract will allow other sublet arrangements to happen, and because it is on the contract, everything is transparent to the original owner, along with the potential for payment to the original owner for the privilege of making these sublet arrangements. 

### Blockchain-powered automobile ignition - "EthCar"

Self-driving cars will be really expensive. Leasing them will probably be important for people to affordably get access. But we don’t need our car all the time. Leasing time windows to people for use of the vehicle will allow people to get access to the car (potentially even telling it to drive to one’s location) for a fixed period of time. All transactions for these rides would run on the chain, and if you get the ride to a location, and you do not need the ride until you are done, you can re-lease time on the vehicle to another lessee in a re-lease transaction. Now there is no wasted “downtime” on the vehicle. The vehicle gates access based on whether the current occupant’s address (e.g. msgSender) is the leaseholder at that point in time. 

### Other potential use cases:

- Renting streaming media
- Library books
- Staking financial assets
- Land deals
- Travel arrangements
- Seats at sports venues

## Specification

```solidity
//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title Time Limited Tokens
/// @notice This interface describes all the events and functions that must
/// be implemented in order to create a Time Limited Token

interface TimeLimitedToken {
    /// @notice The Term structure describes a lease
    /// @param lessee is the lessee for the duration of the lease
    /// @param tokenId is the token for the said lease
    /// @param startTime is the start time of the lease
    /// @param endTime is the end time of the lease
    struct Term {
        address lessee;
        uint256 tokenId;
        uint256 startTime;
        uint256 endTime;
    }

    /// @notice This event is emitted when a new lease is assigned by any mechanism
    /// @param _tokenId of the asset
    /// @param _lessee is the address to which the lease is assigned
    /// @param _start is the start time of the lease
    /// @param _end is the end of the lease
    event Leased(
        uint256 indexed _tokenId,
        address indexed _lessee,
        uint256 _start,
        uint256 _end
    );

    /// @notice This event is emitted when a lease is unleased by any mechanism
    /// @param _tokenId of the asset that is being unleased
    /// @param _lessee is the lessee of the asset to unlease from
    /// @param _start is the start time of the lease that is unleased
    /// @param _end is the end of the lease of the lease that is unleased
    event Unleased(
        uint256 indexed _tokenId,
        address indexed _lessee,
        uint256 _start,
        uint256 _end
    );

    /// @notice This function returns the lessee of the tokenId for a given block
    /// @dev Blocks or Timestamp can be abstracted to hours, days, etc based on business logic
    /// @param _tokenId is the tokenId for which are checking the lesseOf
    /// @param _blockOrTimestamp is the block number  or timestamp at which we are checking who the lessee is
    /// @return address is the address that has the lease of the the _tokenId at _blockOrTimestamp
    function lesseeOf(uint256 _tokenId, uint256 _blockOrTimestamp)
        external
        view
        returns (address);

    /// @notice This function returns a lease for a given a tokenId and block
    /// @param _tokenId is the token for which the lease is being checked
    /// @param _blockOrTimestamp is the the block number or timestamp at which we are checking the lease
    /// @return Term is the lease being returned
    function getLease(uint256 _tokenId, uint256 _blockOrTimestamp)
        external
        view
        returns (Term memory);

    /// @notice This function returns an array of leases (if any) for a given tokenid
    /// @param _tokenId is the token for which the leases are being returned
    /// @return Term[] is the array of leases
    function getLeases(uint256 _tokenId) external view returns (Term[] memory);

    /// @notice This function returns an array of leases given an address for the lessee
    /// @param _address is the lessee
    /// @return Term[] is the array of leases
    function getLeases(address _address) external view returns (Term[] memory);

    /// @notice This function checks if a lease is available for a tokenId
    /// @param _tokenId is the token for which we are checking if a lease is available
    /// @param _start is the start time of the lease we are checking
    /// @param _end is the end time of the lease we are checking
    /// @return Returns true if a lease is available else false
    function isLeaseAvailable(
        uint256 _tokenId,
        uint256 _start,
        uint256 _end
    ) external view returns (bool);

    /// @notice This function transfers the lease from the owner/current lessee/_operator to another
    /// address for a certain token for a given time frame
    /// @param _addressTo is the address to which the lease is being assigned
    /// @param _start is the start time of the lease
    /// @param _end is the end time of the lease
    /// @param _data Additional data with no specified format, sent in call to `_to`
    function lease(
        address _addressTo,
        uint256 _tokenId,
        uint256 _start,
        uint256 _end,
        bytes memory _data
    ) external;

    /// @notice This function transfers the lease from the owner/current lessee/_operator to another
    /// address for a certain token for a given time frame
    /// @dev Calling this version of lease is the same as calling the above one with empty _data field
    /// @param _addressTo is the address to which the lease is being assigned
    /// @param _start is the start time of the lease
    /// @param _end is the end time of the lease
    function lease(
        address _addressTo,
        uint256 _tokenId,
        uint256 _start,
        uint256 _end
    ) external;

    /// @notice This function unleases a token for the duration specified
    /// @dev LeaseCancelled event is emitted
    /// @param _tokenId is the token that is being unleased
    /// @param _start is the start time of the duration being unleased
    /// @param _end is the end time of the duration being unleased
    /// @param _data Additional data with no specified format, sent in call to `_to`
    function unlease(
        uint256 _tokenId,
        uint256 _start,
        uint256 _end,
        bytes memory _data
    ) external;

    /// @notice This function unleases a token for the duration specified
    /// @dev LeaseCancelled event is emitted, Calling this version of unlease
    /// is the same as calling the above one with empty _data field
    /// @param _tokenId is the token that is being unleased
    /// @param _start is the start time of the duration being unleased
    /// @param _end is the end time of the duration being unleased
    function unlease(
        uint256 _tokenId,
        uint256 _start,
        uint256 _end
    ) external;

    /// @notice This function returns the maximum lease duration set
    /// @return Maximum lease duration
    function MAX_LEASE_DURATION() external view returns (uint256); // 60 days

    /// @notice This function returns the minimum lease duration set
    /// @return Minimum lease duration
    function MIN_LEASE_DURATION() external view returns (uint256); // 1 day in 30s blocks, or 86400 for days

    /// @notice This function returns if Timestamp is being used for calculation
    /// @return Returns true if Timestamp is being used else false (Block)
    function USE_TIMESTAMP() external view returns (bool); // Use timestamp instead of block number

    /// @notice This event is emitted when a lease is approved by the current lessee or owner to a future lessee
    /// @param _to is the specific address that is approved for the lease
    /// @param _tokenId is the tokenid of the asset for which lease is being approved
    /// @param _start is the start time for the lease approved
    /// @param _end is the end time for the lease approved
    event LeaseApproval(
        address indexed _to,
        uint256 indexed _tokenId,
        uint256 _start,
        uint256 _end
    );

    /// @notice This event is emitted when the owner sets the lease approval for all
    /// @param _from is the address that approves the lease for everyone (owner address)
    /// @param _operator is the address of the operator/agent that is allowed to manage all the leases of the owner
    /// @param _approved is whether to approve the _operator
    event LeaseApprovalForAll(
        address indexed _from,
        address indexed _operator,
        bool _approved
    );

    /// @notice This function is called when we are approving a lease for a tokenID for
    /// a given time frame and for a given address
    /// @param _addressTo is the address to approve for the said lease
    /// @param _tokenId is the token for which the lease will be approved
    /// @param _start is the start time of the approved lease
    /// @param _end is the end time of the approaved lease

    function approveLease(
        address _addressTo,
        uint256 _tokenId,
        uint256 _start,
        uint256 _end
    ) external;

    /// @notice Given a token and lease start and end time, it returns the address
    /// that is approved for the lease
    /// @param _tokenId is the token for which we are checking the lease
    /// @param _start is the start time of the lease
    /// @param _end is the end time of the lease
    function getLeaseApproved(
        uint256 _tokenId,
        uint256 _start,
        uint256 _end
    ) external view returns (address);

    /// @notice Enable or disable approval for a third party ("operator") to manage
    ///  all of `msg.sender`'s leases
    /// @dev Authorizer(msg.sender) must be the owner
    /// @param _operator the address of a third party that can manage all the leases
    /// on behalf of the owner
    /// @param _approved True if the operator is approved, false to revoke approval
    function setLeaseApprovalForAll(address _operator, bool _approved) external;

    /// This function checks if all the leases are approved
    /// @param _owner is the address for whom to the lease belongs to
    /// @param _operator the address of a third party that can manage all the leases
    /// on behalf of the owner
    function isLeaseApprovedForall(address _owner, address _operator)
        external
        view
        returns (bool);
}
```
**Note**: The key words “MUST”, “MUST NOT”, “REQUIRED”, “SHALL”, “SHALL NOT”, “SHOULD”, “SHOULD NOT”, “RECOMMENDED”, “MAY”, and “OPTIONAL” in this document are to be interpreted as described in RFC 2119.
## Rationale
We believe that industry and type-specific interfaces will become common to make dapps easier to build in specific industries - real estate, transportation, finance. 

There is some prior art that if anything reinforces the gap in standards for this basic rights management need.Transferring ownership is the only way to “lend,” and that leads to a requirement for massive collateralization (see renft.io). This defeats the affordability aspect of a lease arrangement: one must basically be able to afford to buy the house outright before being able to lease it! In another example, Cryptopunks uses a “white space” function to implement a bespoke method for leasing their NFTs for a fixed 99-day period. (cryptopunks.rent)

## Backwards Compatibility and Test Cases
This is designed as an ERC with the lease keyword added to all functions in order to prevent name conflicts. 

## Reference Implementation
[Non-Fungible Travel Services](./nftravel) lets you lease airplanes for future travel. The owners of the airplanes approve leases by travellers in certain future dates. The implementation cuts down on potential gas costs by leveraging the idea of rounding all lease units to complete calendar days (based on midnight-midnight UTC-5). 

## Security and Implementation Considerations
### Gas Consumption
Time-limited tokens are more mathematically involved because of the need to compare potentially quite fine distinctions (e.g. to the second or the block) in time windows. Our standard creates the opportunity to reduce that impact through setting a MIN_LEASE_LENGTH and a START_TIME that, when combined, mean the effective number of combinations falls dramatically. E.g. if the MIN_LEASE_LENGTH is 86,400s, and the START_TIME is midnight UTC-7, only whole days are calculated, allowing internal storage to be much simpler. 

### Lessee rights vs owner rights
Property rights often consider ownership to be "absolute," but lessee rights are not. Enumerating and managing what it means to be a lessee without blindly just checking "lesseeOf" will be important to connecting on-chain knowledge to real-world considerations. 

### Transferability
In a specific case of the preceding, it is entirely probable that a property owner will not want a lessee to further subdivide or reassign their rights. This is common in many residential real estate situations. This proposal would allow that kind of control if the contract considers it explicitly. 

## Copyright
Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).