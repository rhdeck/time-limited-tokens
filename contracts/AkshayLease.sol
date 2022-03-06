//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "hardhat/console.sol";
import "contracts/TimeLimitedToken.sol";

contract ERC721LeaseBase is ERC721URIStorage, TimeLimitedToken {
    constructor() ERC721("Lease", "LEASE") {}

    using SafeMath for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    uint256 public constant TIME_START = 1640970000; // Jan-1-22
    uint256 public constant MAX_DURATION = 60 days; // 60 days
    uint256 public constant MIN_DURATION = 1 days; // 1 day in 30s blocks, or 86400 for days
    bool public constant TIMESTAMP = false; // Use timestamp instead of block number

    // A mapping by tokenId to a mapping of startTime to term
    mapping(uint256 => Term[]) public leasesByToken;
    mapping(address => mapping(uint256 => uint256[])) public leasesByAddress;
    mapping(uint256 => uint256) public lastEndTimeByToken;
    mapping(uint256 => mapping(uint256 => bool)) public daysTaken;
    mapping(uint256 => string) public assets;

    event AssetCreated(address indexed _from, string _tokenURI);

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

    function MAX_LEASE_DURATION() external view override returns (uint256) {
        return MAX_DURATION;
    }

    function MIN_LEASE_DURATION() external view override returns (uint256) {
        return MIN_DURATION;
    }

    function USE_TIMESTAMP() external pure override returns (bool) {
        return TIMESTAMP;
    }

    function getAssets(uint256 _tokenId) public view returns (string memory) {
        return assets[_tokenId];
    }

    function lesseeOf(uint256 _tokenId, uint256 _date)
        external
        view
        override
        returns (address)
    {
        _lesseeOf(_tokenId, _date);
    }

    function _lesseeOf(uint256 _tokenId, uint256 _date)
        internal
        view
        returns (address)
    {
        require(_tokenId != 0);
        require(_date != 0);

        Term[] memory terms = leasesByToken[_tokenId];
        if (terms.length == 0) {
            return address(0);
        }

        for (uint256 i = 0; i < terms.length; i++) {
            if (terms[i].startTime <= _date && _date <= terms[i].endTime) {
                return terms[i].lessee;
            }
        }
        return address(0);
    }

    function getLease(uint256 _tokenId, uint256 _date)
        external
        view
        override
        returns (Term memory)
    {
        _getLease(_tokenId, _date);
    }

    function _getLease(uint256 _tokenId, uint256 _date)
        internal
        view
        returns (Term memory)
    {
        require(_tokenId != 0);
        require(_date != 0);

        Term[] memory terms = leasesByToken[_tokenId];
        if (terms.length == 0) {
            return terms[0];
        }

        for (uint256 i = 0; i < terms.length; i++) {
            if (terms[i].startTime <= _date && _date <= terms[i].endTime) {
                return terms[i];
            }
        }
        return terms[0];
    }

    function getLeases(uint256 _tokenId)
        external
        view
        override
        returns (Term[] memory)
    {
        require(_tokenId != 0);
        return leasesByToken[_tokenId];
    }

    function getLeases(address _address)
        external
        view
        override
        returns (Term[] memory)
    {
        require(false, "Todo");
    }

    function getLeaseEnd(uint256 _tokenId, uint256 _date)
        external
        view
        returns (uint256)
    {
        Term memory term = _getLease(_tokenId, _date);
        if (term.endTime == 0) {
            return 0;
        }
        return term.endTime;
    }

    function getLeaseStart(uint256 _tokenId, uint256 _date)
        public
        view
        returns (uint256)
    {
        Term memory term = getLease(_tokenId, _date);
        if (term.startTime == 0) {
            return 0;
        }
        return term.endTime;
    }

    function isLeaseAvailable(
        uint256 _tokenId,
        uint256 _start,
        uint256 _end
    ) external view override returns (bool) {
        return _isLeaseAvailable(_tokenId, _start, _end);
    }

    function _isLeaseAvailable(
        uint256 _tokenId,
        uint256 _start,
        uint256 _end
    ) internal view returns (bool) {
        // if (_now == 0) {
        //     _now = block.timestamp;
        // }
        uint256 _now = block.timestamp;
        require(_end > _start);
        require(
            _end.sub(_start).mul(86400) <= MAX_DURATION,
            "Lease duration is too long"
        );
        require(
            _end.sub(_start).mul(86400) >= MIN_DURATION,
            "Lease duration is too short"
        );
        uint256 currentContractDate = (_now.sub(TIME_START)).div(86400);
        require(_end >= _start, "End date should be later than start");
        require(
            _start >= currentContractDate,
            "Start date cannot be in the past"
        );

        if (_start > lastEndTimeByToken[_tokenId]) {
            return true;
        }

        for (uint256 j = _start; j <= _end; j++) {
            if (daysTaken[_tokenId][j] == true) {
                return false;
            }
        }
        return true;
    }

    function lease(
        address _addressTo,
        uint256 _tokenId,
        uint256 _start,
        uint256 _end
    ) external override {
        require(_addressTo == msg.sender);
        _lease(_addressTo, _tokenId, _start, _end);
    }

    function lease(
        address _addressTo,
        uint256 _tokenId,
        uint256 _start,
        uint256 _end,
        bytes memory _data
    ) external override {
        require(_addressTo == msg.sender);
        _lease(_addressTo, _tokenId, _start, _end);
    }

    function _lease(
        address _addressTo,
        uint256 _tokenId,
        uint256 _start,
        uint256 _end
    ) internal {
        require(_end > _start);
        require(
            _end.sub(_start).mul(86400) <= MAX_DURATION,
            "Lease duration is too long"
        );
        require(
            _end.sub(_start).mul(86400) >= MIN_DURATION,
            "Lease duration is too short"
        );
        require(_tokenId != 0);
        require(_start != 0);
        require(_end != 0);

        bool leaseAvailable = true;

        Term[] memory terms = leasesByToken[_tokenId];

        if (terms.length != 0) {
            leaseAvailable = _isLeaseAvailable(_tokenId, _start, _end);
            require(leaseAvailable, "Lease not available");
        }

        uint256 startDate = _start.mul(1 days).add(TIME_START);
        uint256 endDate = _end.mul(1 days).add(TIME_START);

        if (leaseAvailable) {
            for (uint256 i = _start; i <= _end; i++) {
                daysTaken[_tokenId][i] = true;
            }

            leasesByToken[_tokenId].push(
                Term(msg.sender, _tokenId, startDate, endDate)
            );
            leasesByAddress[msg.sender][_tokenId].push(terms.length);
            if (lastEndTimeByToken[_tokenId] < _end) {
                lastEndTimeByToken[_tokenId] = _end;
            }
        }
        emit Leased(_tokenId, _addressTo, _start, _end);
    }

    function leaseOnTransfer(
        uint256 _tokenId,
        uint256 _start,
        uint256 _end,
        address _addressTo,
        uint256 _oldStart,
        uint256 _oldEnd
    ) internal {
        require(_end > _start);
        require(
            _end.sub(_start).mul(86400) <= MAX_DURATION,
            "Lease duration is too long"
        );
        require(
            _end.sub(_start).mul(86400) >= MIN_DURATION,
            "Lease duration is too short"
        );
        require(_tokenId != 0);
        require(_start != 0);
        require(_end != 0);

        bool leaseGood = true;

        Term[] memory terms = leasesByToken[_tokenId];

        if (terms.length != 0) {
            leaseGood = _isLeaseAvailable(_tokenId, _start, _end);
        }

        uint256 startDate = _start.mul(1 days).add(TIME_START);
        uint256 endDate = _end.mul(1 days).add(TIME_START);

        uint256 oldStart = _oldStart.sub(TIME_START).div(86400);
        uint256 oldEnd = _oldEnd.sub(TIME_START).div(86400);

        if (leaseGood) {
            for (uint256 i = _start; i <= _end; i++) {
                daysTaken[_tokenId][i] = true;
            }

            leasesByToken[_tokenId].push(
                Term(_addressTo, _tokenId, startDate, endDate)
            );
            leasesByAddress[_addressTo][_tokenId].push(terms.length);

            uint256 newStart = _start.sub(1);
            uint256 newEnd = _end.add(1);

            if (oldEnd - newEnd > 0 && newStart - oldStart == 0) {
                _lease(_addressTo, _tokenId, newEnd, oldEnd);
            }

            if (oldEnd - newEnd == 0 && newStart - oldStart > 0) {
                console.log(oldStart, newStart);
                _lease(_addressTo, _tokenId, oldStart, newStart);
            }
            if (oldEnd - newEnd > 0 && newStart - oldStart > 0) {
                _lease(_addressTo, _tokenId, oldStart, newStart);
                _lease(_addressTo, _tokenId, newEnd, oldEnd);
            }
        }
    }

    function transferLease(
        uint256 _tokenId,
        uint256 _start,
        uint256 _end,
        address _addressTo
    ) external payable {
        require(_tokenId != 0, "Token ID cannot be zero");
        require(_end != 0, "End date cannot be zero");
        require(_start < _end, "Start date must be before end date");

        Term memory term = _getLease(
            _tokenId,
            _start.mul(86400).add(TIME_START)
        );

        require(
            term.lessee == msg.sender,
            "Address does not have rights to this lease"
        );
        require(term.endTime >= _end, "Lessee does not lease past end date");

        uint256 oldStart = term.startTime;
        uint256 oldEnd = term.endTime;

        uint256 oldStartDays = term.startTime.sub(TIME_START).div(86400);
        uint256 oldEndDays = term.endTime.sub(TIME_START).div(86400);

        _unlease(_tokenId, oldStartDays, oldEndDays);
        leaseOnTransfer(_tokenId, _start, _end, _addressTo, oldStart, oldEnd);
    }

    function unlease(
        uint256 _tokenId,
        uint256 _start,
        uint256 _end
    ) external override {
        _unlease(_tokenId, _start, _end);
    }

    function unlease(
        uint256 _tokenId,
        uint256 _start,
        uint256 _end,
        bytes memory
    ) external override {
        _unlease(_tokenId, _start, _end);
    }

    function _unlease(
        uint256 _tokenId,
        uint256 _start,
        uint256 _end
    ) internal {
          require(
            leasesByToken[_tokenId].length > 0,
            "No terms exist for this lease"
        );

        address lessee = lesseeOf(
            _tokenId,
            _start.mul(86400).add(TIME_START)
        );
        require(
            lessee == msg.sender,
            "Address does not have rights to this lease"
        );

        uint256[] memory leases = leasesByAddress[msg.sender][_tokenId];

        uint256 tempStart = getLeaseStart(_tokenId, _start);
        uint256 tempEnd = getLeaseEnd(_tokenId, _start);

        for (uint256 i = 0; i < leases.length; i++) {
            if (leasesByToken[_tokenId][leases[i]].startTime == tempStart) {
            delete leasesByToken[_tokenId][leases[i]];
            leasesByAddress[msg.sender][_tokenId][i] = 0;
            for (uint256 i = tempStart; i <= tempEnd; i++) {
            daysTaken[_tokenId][i] = false;
        }

            } 
        }

        emit LeaseCancelled(_tokenId, msg.sender);
    }

    function mintAsset(
        string memory _name,
        string memory _description,
        string memory _image
    ) external payable {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        // We set the title of our NFT as the generated word.
                        _name,
                        '", "description": "',
                        _description,
                        '", "image": "',
                        _image,
                        '"}'
                    )
                )
            )
        );

        string memory finalTokenUri = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        _safeMint(msg.sender, newItemId);

        _setTokenURI(newItemId, finalTokenUri);

        assets[newItemId] = finalTokenUri;

        emit AssetCreated(msg.sender, finalTokenUri);
    }

    // Adding functions that have been defined in the interface but not defined in the contract yet

    function approveLease(
        address,
        uint256,
        uint256,
        uint256
    ) external pure override {
        require(false, "approveLease isnt implemented yet!");
    }

    function getLeaseApproved(
        uint256,
        uint256,
        uint256
    ) external pure override returns (address) {
        require(false, "getLeaseApproved isnt implemented yet!");
        return address(0);
    }

    function setLeaseApprovalForAll(address, bool) external pure override {
        require(false, "setLeaseApprovalForAll isnt implemented yet!");
    }

    function isLeaseApprovedForall(address, address)
        external
        pure
        override
        returns (bool)
    {
        require(false, "isLeaseApprovedForall isnt implemented yet!");
        return false;
    }
}
