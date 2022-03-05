//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title Time Limited Tokens
/// @notice This interface describes all the events and functions that must be implemented in order to create a
/// Time Limited Token
interface IERC721Lease {
    /// @dev This event is emitted when a new lease is assigned by any mechanism (leaseFrom, unlease, release)
    /// @param _tokenId of the asset
    /// @param _borrower is the address to which the lease is assigned (lessee)
    /// @param _start is the start time of the lease assigned
    /// @param _end is the end of the lease assigned.
    event Leased(
        uint256 indexed _tokenId,
        address indexed _borrower,
        uint256 _start,
        uint256 _end
    );
    /// @dev This event is emitted when a lease is unleased by any mechanism ( unlease, release)
    /// @param _tokenId of the asset that is being unleased
    /// @param _borrower is the lessee of the asset to unlease from
    /// @param _start is the start time of the lease that is unleased
    /// @param _end is the end of the lease of the lease that is unleased
    event Unleased(
        uint256 indexed _tokenId,
        address indexed _borrower,
        uint256 _start,
        uint256 _end
    );

    /// @dev This event is emitted when a lease is approved by the current lessee or owner to a future lessee
    /// @param _from is the address that is approving the lease for a specific address
    /// @param _to is the specific address that is approved for the lease
    /// @param _tokenId is the tokenid of the asset for which lease is being approved
    /// @param _start is the start time for the lease approved
    /// @param _end is the end time for the lease approved
    event LeaseApproval(
        address indexed _from,
        address indexed _to,
        uint256 indexed _tokenId,
        uint256 _start,
        uint256 _end
    );

    /// @dev This event is emitted when the owner sets the lease approval for all
    /// @param _from is the address that approves the lease for everyone (owner address)
    /// @param _operator is the address of the operator/agent that is allowed to manage all the leases of the owner
    /// @param _approved is whether to approve the _operator
    event LeaseApprovalForAll(
        address indexed _from,
        address indexed _operator,
        bool _approved
    );

    /// @notice This function returns the lessee of the tokenId
    /// @param _tokenId is the tokenId for which are checking the lesseOf
    /// @param _block is the block number for which we are checking who the lessee is
    function lesseeOf(uint256 _tokenId, uint256 _block)
        external
        view
        returns (address);

    /// @notice This function is called when we are approving a lease for a tokenID for
    /// a given time frame and for a given address
    /// @param _tokenId is the token for which the lease will be approved
    /// @param _start is the start time of the approved lease
    /// @param _end is the end time of the approaved lease
    /// @param _addressTo is the address to approve for the said lease
    function approveLease(
        uint256 _tokenId,
        uint256 _start,
        uint256 _end,
        address _addressTo
    ) external;

    /// @notice @greenidiot can we add these as functions?
    function MAX_LEASE_DURATION() external pure returns (uint256); // 60 days

    function MIN_LEASE_DURATION() external pure returns (uint256); // 1 day in 30s blocks, or 86400 for days

    function USE_TIMESTAMP() external pure returns (bool); // Use timestamp instead of block number

    /// @notice Check again
    function getLeaseApproved(uint256 _tokenId) external view returns (address);

    /// @notice This function transfers the lease from the owner/current lessee/_operator to another
    /// address for a certain token for a given time frame
    /// @param _addressFrom is the address assigning the lease
    /// @param _addressTo is the address to which the lease is being assigned
    /// @param _start is the start time of the lease
    /// @param _end is the end time of the lease
    /// @param _data Additional data with no specified format, sent in call to `_to`
    function leaseFrom(
        address _addressFrom,
        address _addressTo,
        uint256 tokenId,
        uint256 _start,
        uint256 _end,
        bytes memory _data
    ) external payable;

    /// @notice transfers ownership of the lease from the current owner to a third party -- THE CALLER IS RESPONSIBLE
    ////// TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING the lease
    /// @param _addressFrom is the address assigning the lease
    /// @param _addressTo is the address to which the lease is being assigned
    /// @param _start is the start time of the lease
    /// @param _end is the end time of the lease
    function leaseFrom(
        address _addressFrom,
        address _addressTo,
        uint256 tokenId,
        uint256 _start,
        uint256 _end
    ) external payable;

    /// @notice Unleases a lease for a token for  certain timeframe
    /// @param _tokenId is the token for which the lease is being unleased
    /// @param _start is the start time of the timeframe of the lease
    /// @param _end is the end time of the timeframe of the lease
    function unlease(
        uint256 _tokenId,
        uint256 _start,
        uint256 _end
    ) external;

    /// Uses message.sender as the authorizer
    /// @notice Enable or disable approval for a third party ("operator") to manage
    ///  all of `msg.sender`'s leases
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
