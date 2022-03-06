//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC721Lease.sol";

contract LeaseSimple is IERC721Lease {
    //Overrideable Constants
    uint256 public constant MAX_LEASE_DURATION = 60 days / 30; // 60 days
    uint256 public constant MIN_LEASE_DURATION = 2880; // 1 day in 30s blocks, or 86400 for days
    bool public constant USE_TIMESTAMP = false; // Use timestamp instead of block number

    function msgSender() internal returns (address) {
        return msg.sender;
    }

    // an array of tokens
    struct Term {
        address lessee;
        uint256 tokenId;
        uint256 startTime;
        uint256 endTime;
    }
    // A mapping by tokenId to a mapping of startTime to term
    mapping(uint256 => Term[]) leasesByToken;
    mapping(address => Term[]) leasesByAddress;
    mapping(uint256 => uint256) lastEndTimeByToken;
    mapping(bytes32 => address) leaseApprovals;
    mapping(uint256 => bool) leaseAgents;

    function lesseeOf(uint256 _tokenId, uint256 _block)
        external
        view
        returns (address)
    {
        require(_tokenId != 0);
        require(_block != 0);

        Term[] memory terms = leasesByToken[_tokenId];
        if (terms.length == 0) {
            return _ownerOf(_tokenId);
        }
        for (uint256 i = 0; i < terms.length; i++) {
            if (terms[i].startTime <= _block && _block <= terms[i].endTime) {
                return terms[i].lessee;
            }
        }
        return _ownerOf(_tokenId);
    }

    function leaseAt(uint256 _tokenId, uint256 _block)
        public
        view
        returns (Term memory)
    {
        require(_tokenId != 0);
        require(_block != 0);

        Term[] memory terms = leasesByToken[_tokenId];
        if (terms.length == 0) {
            return Term(address(0), 0, 0, 0);
        }

        for (uint256 i = 0; i < terms.length; i++) {
            if (terms[i].startTime <= _block && _block <= terms[i].endTime) {
                return terms[i];
            }
        }
        return Term(address(0), 0, 0, 0);
    }

    function getLeases(uint256 _tokenId) external view returns (Term[] memory) {
        require(_tokenId != 0);
        return leasesByToken[_tokenId];
    }

    function getLeaseEnd(uint256 _tokenId, uint256 _block)
        external
        view
        returns (uint256)
    {
        Term memory term = leaseAt(_tokenId, _block);
        if (term.endTime == 0) {
            return 0;
        }
        return term.endTime;
    }

    function getNow() internal view returns (uint256) {
        if (USE_TIMESTAMP) {
            return block.timestamp;
        } else {
            return block.number;
        }
    }

    function _ownerOf(uint256 _tokenId) internal view returns (address) {
        // return ownerOf(_tokenId);
        return address(0);
    }

    function isAvailable(
        uint256 _tokenId,
        uint256 _start,
        uint256 _end,
        address _holderAddress,
        uint256 _now
    ) public view returns (address, bool) {
        if (_now == 0) {
            _now = getNow();
        }
        require(_end >= _start);
        require(_start >= _now);
        uint256 thisBlock = _start;

        if (_start > lastEndTimeByToken[_tokenId]) {
            return (_ownerOf(_tokenId), false);
        }
        Term[] memory terms = leasesByToken[_tokenId];
        if (terms.length == 0) {
            return (_ownerOf(_tokenId), false);
        }
        while (thisBlock <= _end) {
            uint256 index = 0;
            while (index < terms.length) {
                if (thisBlock >= terms[index].startTime) {
                    if (thisBlock <= terms[index].endTime) {
                        if (terms[index].lessee != _holderAddress) {
                            return (_holderAddress, true);
                            break;
                        }
                    }
                }
                index++;
            }
            thisBlock = thisBlock + MIN_LEASE_DURATION; // If we have a mimimum lease duration, we need to increment thisBlock by that much
            if (thisBlock > _end) {
                return (_ownerOf(_tokenId), false);
            }
        }
        return (_holderAddress, true);
    }

    /*
        //Example: Reletting middle of my lease (456)
        123456789   // Old lease for A
           456      // Unlease for A
        123   789   // New Leases for A
           456      // New Lease for B

        123456789   // Old lease for A
        123         // Unlease for A
           456789   // New Lease for A
        123         // New Lease for B

        123456789   // Lease for A
        123         // New lease for B

        */

    function approveLease(
        uint256 _tokenId,
        uint256 _start,
        uint256 _end,
        address _addressTo
    ) external {
        (address lessee, bool leased) = isAvailable(
            _tokenId,
            _start,
            _end,
            msgSender(),
            0
        );
        require(lessee == msgSender());
        bytes32 approval = keccak256(abi.encodePacked(_tokenId, _start, _end));
        leaseApprovals[approval] = _addressTo;
        emit LeaseApproval(msgSender(), _addressTo, _tokenId, _start, _end);
    }

    function _isLeaseApproved(
        uint256 _tokenId,
        uint256 _start,
        uint256 _end,
        address s_addressTo
    ) internal view returns (bool) {
        bytes32 approval = keccak256(abi.encodePacked(_tokenId, _start, _end));
        return leaseApprovals[approval] != address(0);
    }

    function _isAuthorized(address _addressFrom) internal view returns (bool) {
        return _addressFrom == msgSender();
    }

    function leaseFrom(
        address _addressFrom,
        address _addressTo,
        uint256 _tokenId,
        uint256 _start,
        uint256 _end
    ) external payable {
        require(_tokenId != 0);
        require(_start != 0);
        require(_end != 0);

        //Either this is the lessor of the token for this span, or it is the owner of the token if it is available, or it is
        require(
            (msgSender() == _addressFrom) ||
                _isLeaseApproved(_tokenId, _start, _end, _addressTo)
        );

        (, bool avail) = isAvailable(_tokenId, _start, _end, _addressFrom, 0);
        require(avail);

        //Now we need to split the lease in two. Which lease encompasses this one?
        //Make the new lease
        Term memory term = Term(_addressTo, _tokenId, _start, _end);
        //find wrapping lease
        Term memory oldLease = leaseAt(_tokenId, _start);
        if (oldLease.startTime == 0) {
            //No wrapping lease, just add the new lease
            leasesByToken[_tokenId].push(term);
            emit Leased(_tokenId, _addressTo, _start, _end);
        } else if (oldLease.startTime == _start) {
            //We are cutting this lease and adding the new one.
            Term memory newLease = Term(
                _addressFrom,
                _tokenId,
                _end + 1,
                oldLease.endTime
            );
            for (uint256 i = 0; i < leasesByToken[_tokenId].length; i++) {
                if (leasesByToken[_tokenId][i].startTime == _start) {
                    leasesByToken[_tokenId][i] = newLease;
                    break;
                }
            }
            leasesByToken[_tokenId].push(term);
            emit Unleased(_tokenId, _addressFrom, _start, _end);
            emit Leased(_tokenId, _addressFrom, _end, oldLease.endTime);
            emit Leased(_tokenId, _addressTo, _start, _end);
        } else if (oldLease.endTime == _end) {
            Term memory newLease = Term(
                _addressFrom,
                _tokenId,
                oldLease.startTime,
                _start - 1
            );
            for (uint256 i = 0; i < leasesByToken[_tokenId].length; i++) {
                if (
                    leasesByToken[_tokenId][i].startTime == oldLease.startTime
                ) {
                    leasesByToken[_tokenId][i] = newLease;
                    break;
                }
            }
            leasesByToken[_tokenId].push(term);
            emit Unleased(_tokenId, _addressFrom, _start, _end);
            emit Leased(_tokenId, _addressFrom, _start, oldLease.startTime - 1);
            emit Leased(_tokenId, _addressTo, _start, _end);
        }
        //Add the new lease to the mapping
        leasesByToken[_tokenId].push(term);
        Term[] memory terms = leasesByToken[_tokenId];
        // t = term;
        // leasesByToken[_tokenId] = terms;

        emit Unleased(_tokenId, _addressFrom, _start, _end);
        if (_end > lastEndTimeByToken[_tokenId]) {
            lastEndTimeByToken[_tokenId] = _end;
        }
    }

    //emit borrow
    //emit return

    function unlease(
        uint256 _tokenId,
        uint256 _start,
        uint256 _end
    ) external {}

    function setLeaseApprovalForAll(address _operator, bool _approved)
        external
    {
        leaseAgents[keccak256(_operator, msgSender())] = _approved;
        emit LeaseApprovalForAll(msgSender(), _operator, _approved);
    }

    function isLeaseApprovedForall(address _owner, address _operator)
        external
        view
        returns (bool)
    {
        return leaseAgents[keccak256(_operator, _owner)];
    }
}
