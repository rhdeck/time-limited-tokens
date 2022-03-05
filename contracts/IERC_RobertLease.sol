//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title Time Limited Tokens
/// @notice This interface describes all the events and functions that must
/// be implemented in order to create a Time Limited Token

interface IERC_RobertLease {
    /// --------NOT SURE WE NEED THIS ONE --------
    /// @dev This even is asserted when a new Asset is minted
    /// @param _from is the address that is minting the asset
    /// @param _tokenURI is the URI for the asset that is minted
    event AssetCreated(address indexed _from, string _tokenURI);

    /// @notice The Term structure describes a lease
    /// @param lessee is the lessee for the duration of the lease
    /// @param tokenId is the token for the said lease
    /// @param startTime is the start time of the lease
    /// @param enddTime is the end time of the lease
    struct Term {
        address lessee;
        uint256 tokenId;
        uint256 startTime;
        uint256 endTime;
    }

    /// @notice This event is emitted when a new lease is assigned by any mechanism (leaseFrom, unlease, release)
    /// @param _tokenId of the asset
    /// @param _lessee is the address to which the lease is assigned (lessee)
    /// @param _start is the start time of the lease assigned
    /// @param _end is the end of the lease assigned.
    event Leased(
        uint256 indexed _tokenId,
        address indexed _lessee,
        uint256 _start,
        uint256 _end
    );

    /// @notice This event is emitted when a lease is tranferred for a token from a lessee to another address
    /// @param _tokenId is the token for which the lease is being transferred.
    /// @param _lessee is the address who currently has the lease and is transferring it to another address
    /// @param _addressTo is the address to which the lease is being transferred
    /// @param _start is the start time of the lease being transferred
    /// @param _end is the end time of the lease being transferred
    event LeaseTransferred(
        uint256 indexed _tokenId,
        address indexed _lessee,
        address indexed _addressTo,
        uint256 _start,
        uint256 _end
    );

    /// @notice This even is emitted when a lease is cancelled(unleased)
    /// @dev Lessee is returned by calling lesseeOf(_tokenID, _start,_end)
    /// @param _tokenId is the token for which the lease is cancelled
    /// @param _lessee is the address for which the lease is cancelled
    event LeaseCancelled(uint256 indexed _tokenId, address indexed _lessee);

    /// @notice This function returns the lessee of the tokenId for a given block
    /// @dev Blocks can be abstracted to hours, days, etc based on business logic
    /// @param _tokenId is the tokenId for which are checking the lesseOf
    /// @param _block is the block number at which we are checking who the lessee is
    /// @return address is the address that has the lease of the the _tokenId at _block
    function lesseeOf(uint256 _tokenId, uint256 _block)
        external
        view
        returns (address);

    /// @notice This function returns a lease for a given a tokenId and block
    /// @param _tokenId is the token for which the lease is being checked
    /// @param _block is the the block number at which we are checking the lease
    /// @return Term is the lease being returned
    function getLease(uint256 _tokenId, uint256 _block)
        external
        view
        returns (Term memory);

    /// @notice This function returns an array of leases (if any) for a given tokenid
    /// @param _tokenId is the token for which the leases are being returned
    /// @return Term[] is the array of leases
    function getLeases(uint256 _tokenId) external view returns (Term[] memory);

    /// ------ NOT SURE IF THIS FUNCTION IS NEEDED IN IERC--------
    /// @notice This function gets the lease end date for a given token
    /// @param _tokenId is the token for which the end  date is being returned
    /// @param _block is the block number of a lease term for which we are getting an end
    /// @return Returns a block number for the end of the lease
    function getLeaseEnd(uint256 _tokenId, uint256 _block)
        external
        view
        returns (uint256);

    /// -----------Check what now is --------
    /// @notice This function checks if a lease is available for a tokenId
    /// @param _tokenId is the token for which we are checking if a lease is available
    /// @param _start is the start time of the lease we are checking
    /// @param _end is the end time of the lease we are checking
    /// @param _now is the current block timestamp
    /// @return Returns true if a lease is available else false
    function isLeaseAvailable(
        uint256 _tokenId,
        uint256 _start,
        uint256 _end,
        uint256 _now
    ) external view returns (bool);

    /// @notice This function is called to lease a token for a given duration
    /// @dev Leased event is emitted when calling this function
    /// @param _start is the start time of the lease
    /// @param _end is the end time of the lease
    function lease(
        uint256 _tokenId,
        uint256 _start,
        uint256 _end
    ) external;

    /// @notice This function transfer a lease for a tokenId to another duration for
    /// a given duration
    /// @dev This function calls the unlease function to first
    /// @param _tokenId is the token for which the lease is being transferred
    /// @param _start is the start time of the lease
    /// @param _end is the end time of the lease
    // function transferLease(
    //     uint256 _tokenId,
    //     uint256 _start,
    //     uint256 _end,
    //     address _addressTo
    // ) external payable;

    /// @notice This function unleases a token for the duration specified
    /// @dev LeaseCancelled event is emitted
    /// @param _tokenId is the token that is being unleased
    /// @param _start is the start time of the duration being unleased
    /// @param _end is the end time of the duration being unleased
    function unlease(
        uint256 _tokenId,
        uint256 _start,
        uint256 _end
    ) external payable;

    /// @notice This function returns the maximum lease duration set
    /// @return Maximum lease duration
    function MAX_LEASE_DURATION() external pure returns (uint256); // 60 days

    /// @notice This function returns the minimum lease duration set
    /// @return Minimum lease duration
    function MIN_LEASE_DURATION() external pure returns (uint256); // 1 day in 30s blocks, or 86400 for days

    ///--------- FROM OTHER IERC for reference----------------

    /// @notice This event is emitted when a lease is approved by the current lessee or owner to a future lessee
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

    /// @notice Check again
    function getLeaseApproved(uint256 _tokenId) external view returns (address);

    /// @notice This function transfers the lease from the owner/current lessee/_operator to another
    /// address for a certain token for a given time frame
    /// @param _addressFrom is the address assigning the lease
    /// @param _addressTo is the address to which the lease is being assigned
    /// @param _start is the start time of the lease
    /// @param _end is the end time of the lease
    /// @param _data Additional data with no specified format, sent in call to `_to`
    // function leaseFrom(
    //     address _addressFrom,
    //     address _addressTo,
    //     uint256 tokenId,
    //     uint256 _start,
    //     uint256 _end,
    //     bytes memory _data
    // ) external payable;

    /// @notice transfers ownership of the lease from the current owner to a third party -- THE CALLER IS RESPONSIBLE
    ////// TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING the lease
    /// @param _addressFrom is the address assigning the lease
    /// @param _addressTo is the address to which the lease is being assigned
    /// @param _start is the start time of the lease
    /// @param _end is the end time of the lease
    // function leaseFrom(
    //     address _addressFrom,
    //     address _addressTo,
    //     uint256 tokenId,
    //     uint256 _start,
    //     uint256 _end
    // ) external payable;

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

    function USE_TIMESTAMP() external pure returns (bool); // Use timestamp instead of block number
}
