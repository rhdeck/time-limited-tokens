//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ITemporalNFT.sol";

contract ERC721LeaseBase is IERC721Lease {
    //Properties

    uint256 public constant MAX_LEASE_DURATION = 60 days / 30; // 60 days
    uint256 public constant MIN_LEASE_DURATION = 2880; // 1 day in 30s blocks, or 86400 for days
    bool public constant USE_TIMESTAMP = false; // Use timestamp instead of block number
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

    function lesseeOf(uint256 _tokenId, uint256 _block)
        external
        view
        returns (address)
    {
        require(_tokenId != 0);
        require(_block != 0);

        Term[] memory terms = leasesByToken[_tokenId];
        if (terms.length == 0) {
            return address(0);
        }

        for (uint256 i = 0; i < terms.length; i++) {
            if (terms[i].startTime <= _block && _block <= terms[i].endTime) {
                return terms[i].lessee;
            }
        }
        return address(0);
    }

    function getLease(uint256 _tokenId, uint256 _block)
        external
        view
        returns (Term memory)
    {
        require(_tokenId != 0);
        require(_block != 0);

        Term[] memory terms = leasesByToken[_tokenId];
        if (terms.length == 0) {
            return Term(0, 0, 0, 0);
        }

        for (uint256 i = 0; i < terms.length; i++) {
            if (terms[i].startTime <= _block && _block <= terms[i].endTime) {
                return terms[i];
            }
        }
        return Term(0, 0, 0, 0);
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
        Term memory term = getLease(_tokenId, _block);
        if (term.endTime == 0) {
            return 0;
        }
        return term.endTime;
    }

    function getNow() internal view returns (uint256) {
        if (USE_TIMESTAMP) {
            return now;
        } else {
            return block.number;
        }
    }

    function isLeaseAvailable(
        uint256 _tokenId,
        uint256 _start,
        uint256 _end,
        uint256 _now
    ) view returns (bool) {
        if (_now == 0) {
            _now = getNow();
        }
        require(_end >= _start);
        require(_start >= _now);
        uint256 thisBlock = _start;

        if (_start > lastEndTimeByToken[_tokenId]) {
            return true;
        }
        bool isOk = true;
        while (thisBlock <= _end) {
            uint256 index = 0;
            while (index < terms.length) {
                if (thisBlock >= terms[index].startTime) {
                    if (thisBlock <= terms[index].endTime) {
                        return false;
                    }
                    //@TODO WHERE WE LEFT OFF ON TUESDAY NIGHT
                    // thisBlock = terms[index].endTime + 1;
                    // if(thisBlock > _end) {
                    //     return false;
                    // }
                }
                index++;
            }
            thisBlock = thisBlock + MIN_LEASE_DURATION; // If we have a mimimum lease duration, we need to increment thisBlock by that much
        }
        return true;
    }

    function lease(
        uint256 _tokenId,
        uint256 _start,
        uint256 _end
    ) external payable {
        require(_tokenId != 0);
        require(_start != 0);
        require(_end != 0);

        Term[] memory terms = leasesByToken[_tokenId];
        if (terms.length == 0) {
            //we good
        }

        //AAAAAAAAAAAAAABBBBBBBBBCCCCCC-------------DDDDDDDEEEEEEEEFFFFFFFFF

        uint256 thisBlock = _start;
        bool isOk = true;
        if (_start > lastEndTimeByToken[_tokenId]) {
            return true;
        }
        while (thisBlock <= _end) {
            uint256 index = 0;
            while (index < terms.length) {
                if (thisBlock >= terms[index].startTime) {
                    if (thisBlock <= terms[index].endTime) {
                        isOk = false;
                        break;
                    }
                    thisBlock = terms[index].endTime + 1;
                }
                index++;
            }
        }
        for (uint256 i = 0; i < terms.length; i++) {
            if (terms[i].startTime <= _start && _start <= terms[i].endTime) {
                return terms[i];
            }
            if (terms[i].startTime <= _end && _end <= terms[i].endTime) {
                return terms[i];
            }
        }

        require(lesseeOf(_tokenId, _start) == address(0));
        require(lesseeOf(_tokenId, _end) == address(0));

        require(_end > _start);
        require(_end - _start <= MAX_LEASE_DURATION);
        require(_end - _start >= MIN_LEASE_DURATION);

        // Check if the token is already leased
        Term memory term = getLease(_tokenId, block.timestamp);
        require(term.endTime == 0);

        // Check if the caller is the owner of the token
        require(ownerOf(_tokenId) == msg.sender);

        // // Check if the caller has enough balance
        // require(msg.value >= _end - _start);

        // // Check if the caller has enough allowance
        // require(allowance(msg.sender, address(this)) >= _end - _start);

        // // Check if the caller has enough balance
        // require(balanceOf(msg.sender) >= _end - _start);

        // // Check if the caller has enough allowance
        // require(allowance(msg.sender, address(this)) >= _end - _start);

        // // Check if the caller has enough balance
        // require(balanceOf(msg.sender) >= _end - _start);

        // // Check if the caller has enough allowance
        // require(allowance(msg.sender, address(this)) >= _end - _start);

        // // Check if the caller has enough balance
        // require(balanceOf(msg.sender) >= _end - _start);

        // // Check if the caller has enough allowance
        // require(allowance(msg.sender, address(this)) >= _end - _start);

        // // Check if the caller has enough balance
        // require(balanceOf(msg.sender) >= _end - _start);

        // // Check if the caller has enough allowance
        // require(allowance(msg.sender, address(this)) >= _end - _start);

        // // Check if the caller has enough balance
        // require(balanceOf(msg.sender) >= _end - _start);

        // // Check if the caller has enough allowance
        // require(allowance(msg.sender, address(this)) >= _end -

        if (_end > lastEndTimeByToken[_tokenId]) {
            lastEndTimeByToken[_tokenId] = _end;
        }
    }

    // For a lease in period ABC, where you sublet period B, you would generate new lease events for A and C for you, and a return event for ABC for you, and a lease event for them for B
    //emit lease events (split in the original lease, and the new re-lease)
    //emit return (undo of rights by the original lessee)

    function approveRelease(
        uint256 _tokenId,
        uint256 _start,
        uint256 _end,
        address _addressTo
    ) external {}

    function releaseFrom(
        address _addressFrom,
        address _addressTo,
        uint256 tokenId,
        uint256 _start,
        uint256 _end
    ) external payable {}

    //emit borrow
    //emit return

    // function uri(uint256 _tokenId) external view returns (string memory);

    // function hash(uint256 _tokenId) external view returns (uint256);

    // function mint(string memory _tokenURI, uint256 hash) external;

    //emit mint

    function unlease(
        uint256 _tokenId,
        uint256 _start,
        uint256 _end
    ) external {}
}
