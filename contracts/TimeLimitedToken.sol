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
