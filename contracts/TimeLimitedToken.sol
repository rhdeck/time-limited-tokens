//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "contracts/ITimeLimitedToken.sol";
import "hardhat/console.sol";

contract TimeLimitedToken is ERC721URIStorage, ITimeLimitedToken {
    constructor() ERC721("Lease", "LEASE") {}

    using SafeMath for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    uint256 public constant TIME_START = 1640970000; // Jan-1-22
    uint256 constant MAX_DURATION = 60 days; // 60 days
    uint256 constant MIN_DURATION = 1 days; // 1 day in 30s blocks, or 86400 for days
    bool public constant TIMESTAMP = false; // Use timestamp instead of block number

    // A mapping by tokenId to a mapping of startTime to term
    mapping(uint256 => Term[]) public leasesByToken;
    mapping(address => Term[]) public leasesByAddress;
    mapping(uint256 => uint256) public lastEndTimeByToken;
    mapping(uint256 => string) public assets;
    mapping(bytes32 => address) public approvalsbyLease;
    mapping(address => mapping(address => bool)) public approvalbyAddress;

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

    function MAX_LEASE_DURATION() external pure override returns (uint256) {
        return MAX_DURATION;
    }

    function MIN_LEASE_DURATION() external pure override returns (uint256) {
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
        return _lesseeOf(_tokenId, _date);
    }

    //changed from external to public
    // maybe need to add agent as a possible possessor?
    function possessorOf(uint256 _tokenId, uint256 _date)
        public
        view
        returns (address)
    {
        address lessee = _lesseeOf(_tokenId, _date);
        if (lessee == address(0)) return ownerOf(_tokenId);
        return lessee;
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
            return address(0); //Because the property is currently not leased
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
        return _getLease(_tokenId, _date);
    }

    function _getLease(uint256 _tokenId, uint256 _date)
        internal
        view
        returns (Term memory)
    {
        require(_tokenId != 0);
        require(_date != 0);

        Term[] memory terms = leasesByToken[_tokenId];
        // console.log("Terms length", _tokenId, terms.length);
        if (terms.length == 0) {
            return Term(address(0), 0, 0, 0);
        }
        // console.log("_date is :", _date);

        for (uint256 i = 0; i < terms.length; i++) {
            if ((terms[i].startTime <= _date) && (_date <= terms[i].endTime)) {
                return terms[i];
            }
        }
        // console.log("getlease could not find a lease!!!");
        return Term(address(0), 0, 0, 0);
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

    //@TODO Requires leasesbyaddress to be populated
    function getLeases(address _address)
        external
        view
        override
        returns (Term[] memory)
    {
        require(_address != address(0));
        return leasesByAddress[_address];
    }

    function getLeaseEnd(uint256 _tokenId, uint256 _date)
        external
        view
        returns (uint256)
    {
        return _getLeaseEnd(_tokenId, _date);
    }

    function _getLeaseEnd(uint256 _tokenId, uint256 _date)
        internal
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
        internal
        view
        returns (uint256)
    {
        Term memory term = _getLease(_tokenId, _date);
        if (term.startTime == 0) {
            return 0;
        }
        return term.startTime;
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
        require(_end > _start);
        require(_end.sub(_start) <= MAX_DURATION);
        require(_end.sub(_start) >= MIN_DURATION);

        uint256 _now = block.timestamp;

        if (_start < _now) {
            return false;
        }

        if (_start > lastEndTimeByToken[_tokenId]) {
            return true;
        }

        //iterate over leasebytoken
        if (leasesByToken[_tokenId].length == 0) {
            return true;
        }
        for (uint256 i = 0; i < leasesByToken[_tokenId].length; i++) {
            if (
                leasesByToken[_tokenId][i].startTime <= _start &&
                _start <= leasesByToken[_tokenId][i].endTime
            ) {
                return false;
            }
            if (
                leasesByToken[_tokenId][i].startTime <= _end &&
                _end <= leasesByToken[_tokenId][i].endTime
            ) {
                return false;
            }
            if (
                _start <= leasesByToken[_tokenId][i].startTime &&
                leasesByToken[_tokenId][i].startTime <= _end
            ) {
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
        _lease(_addressTo, _tokenId, _start, _end);
    }

    function lease(
        address _addressTo,
        uint256 _tokenId,
        uint256 _start,
        uint256 _end,
        bytes memory // _data - not used
    ) external override {
        _lease(_addressTo, _tokenId, _start, _end);
    }

    function _lease(
        address _addressTo,
        uint256 _tokenId,
        uint256 _start,
        uint256 _end
    ) internal {
        require(_tokenId != 0);
        require(_start != 0);
        require(_end != 0);
        require(_end > _start);
        require(_end.sub(_start) <= MAX_DURATION);
        require(_end.sub(_start) >= MIN_DURATION);
        // require(_isApproved(_addressTo, _tokenId, _start, _end));

        if (_isLeaseAvailable(_tokenId, _start, _end)) {
            bool found = false;
            address _owner = ownerOf(_tokenId);
            if (msg.sender == _owner) {
                found = true;
            } else {
                if (approvalbyAddress[_owner][msg.sender] == true) {
                    found = true;
                }
            }
            require(
                found ||
                    approvalsbyLease[_hashLease(_tokenId, _start, _end)] ==
                    _addressTo
            );
            // console.log("onlymakelease runs");
            _makeLease(_addressTo, _tokenId, _start, _end);
        } else {
            Term memory start_lease = _getLease(_tokenId, _start);
            Term memory end_lease = _getLease(_tokenId, _end);
            require(start_lease.startTime == end_lease.startTime);

            address possessor = start_lease.lessee;
            bool found = false;
            if (msg.sender == possessor) {
                found = true;
            } else {
                if (approvalbyAddress[possessor][msg.sender] == true) {
                    found = true;
                }
            }
            require(
                found ||
                    approvalsbyLease[_hashLease(_tokenId, _start, _end)] ==
                    _addressTo
            );
            // console.log("both makelease and unlease run");
            _unlease(_tokenId, _start, _end);
            _makeLease(_addressTo, _tokenId, _start, _end);
        }
    }

    function _makeLease(
        address _addressTo,
        uint256 _tokenId,
        uint256 _start,
        uint256 _end
    ) internal {
        // console.log("Make lease starting");
        // console.log(" Address to is :", _addressTo);
        // console.log(" token id  is :", _tokenId);
        // console.log(" start is :", _start);
        // console.log(" end is :", _end);
        // console.log("/Make lease starting");

        require(_end > _start);
        require(_end.sub(_start) <= MAX_DURATION);
        // console.log("_end is :", _end);
        // console.log("_start is :", _start);
        // console.log("end.sub(start) is :", _end.sub(_start));
        // console.log("MIN_DURATION is :", MIN_DURATION);
        require(_end.sub(_start) >= MIN_DURATION);
        require(_tokenId != 0);
        require(_start != 0);
        require(_end != 0);

        leasesByToken[_tokenId].push(Term(_addressTo, _tokenId, _start, _end));

        // Pushing lease term to leasesbyaddress
        leasesByAddress[_addressTo].push(
            Term(_addressTo, _tokenId, _start, _end)
        );

        if (lastEndTimeByToken[_tokenId] < _end) {
            lastEndTimeByToken[_tokenId] = _end;
        }
        emit Leased(_tokenId, _addressTo, _start, _end);
        // console.log("Make lease ends");
    }

    function unlease(
        uint256 _tokenId,
        uint256 _start,
        uint256 _end
    ) external override {
        Term memory start_lease = _getLease(_tokenId, _start);
        Term memory end_lease = _getLease(_tokenId, _end);
        require(start_lease.startTime > 0);
        require(start_lease.startTime == end_lease.startTime);

        address possessor = start_lease.lessee;
        bool found = false;
        if (msg.sender == possessor) {
            found = true;
        } else {
            if (approvalbyAddress[possessor][msg.sender] == true) {
                found = true;
            }
        }

        require(found);

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

    // TODO: Unlease should fail when trying to lease overlapping period
    function _unlease(
        uint256 _tokenId,
        uint256 _start,
        uint256 _end
    ) internal {
        // console.log("Starting Unlease");
        // console.log(" _tokenId is :", _tokenId);
        // console.log(" _start is: ", _start);
        // console.log(" _end is : ", _end);
        // console.log("/Starting Unlease");
        require(leasesByToken[_tokenId].length > 0);

        Term memory currentLease = _getLease(_tokenId, _start);
        // console.log("current lease tokenId is : ", currentLease.tokenId);
        uint256 tempStart = currentLease.startTime; //old lease start
        uint256 tempEnd = currentLease.endTime; //old lease end

        // console.log("tempstart is :", tempStart);
        // console.log("tempend is :", tempEnd);
        // console.log("_start is :", _start);

        require(_end > tempStart + 1);
        require(_start < tempEnd - 1);
        require(_end < tempEnd + 1);
        require(_start > tempStart - 1);

        // require(_isAuthorized(currentLease)); //checking if the msg.sender is the lessee for the lease being unleased

        for (uint256 i = 0; i < leasesByToken[_tokenId].length; i++) {
            if (leasesByToken[_tokenId][i].startTime == tempStart) {
                address lessee = leasesByToken[_tokenId][i].lessee;
                delete leasesByToken[_tokenId][i];
                // TODO:  delete leasebyaddress

                if (tempStart == _start && tempEnd == _end) {
                    // situation where we are completely unleasing the lease
                    // NO-OP
                } else if (tempStart == _start) {
                    //issue a new lease from _end+1 to
                    _makeLease(lessee, _tokenId, _end + 1, tempEnd);
                } else if (tempEnd == _end) {
                    // case when lease to unlease its end date is the same
                    _makeLease(lessee, _tokenId, tempStart, _start - 1);
                } else {
                    // case when unleased part is in the middle of current lease
                    _makeLease(lessee, _tokenId, tempStart, _start - 1);
                    _makeLease(lessee, _tokenId, _end + 1, tempEnd);
                }
                break;
            }
        }
        emit Unleased(_tokenId, msg.sender, _start, _end);
    }

    //TODO: Look at it again
    // function _isAuthorized(Term memory lease) internal returns (bool) {
    //     return (msg.sender == lease.lessee);
    //     // return _owner == msg.sender || msg.sender == owner;
    // }

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
        address _addressTo,
        uint256 _tokenId,
        uint256 _start,
        uint256 _end
    ) external override {
        // if the lease on both the start and end date is the same lease
        // or if the token is not leased for that period then find the possessor of the lease for that period
        // if no lease then check for msg.sender is the owner of the token
        // also check for the agent of the owner of the token --- stll need to do this---

        // If the lease is not found between for the period check if msg.sender is the owner
        if (_isLeaseAvailable(_tokenId, _start, _end)) {
            bool found = false;
            address _owner = ownerOf(_tokenId);
            if (msg.sender == _owner) {
                found = true;
            } else {
                if (approvalbyAddress[_owner][msg.sender] == true) {
                    found = true;
                }
            }
            require(found);
            // Now that msg.sender is the owner of the token we can approve the lease
            bytes32 hashed_lease = _hashLease(_tokenId, _start, _end);
            approvalsbyLease[hashed_lease] = _addressTo;
            emit LeaseApproval(_addressTo, _tokenId, _start, _end);
        } else {
            // it is leased during the period, so compare the hashed lease using start date with the hashed lease of the end date
            Term memory start_lease = _getLease(_tokenId, _start);
            Term memory end_lease = _getLease(_tokenId, _end);
            require(start_lease.startTime == end_lease.startTime);

            address possessor = start_lease.lessee;
            bool found = false;
            if (msg.sender == possessor) {
                found = true;
            } else {
                if (approvalbyAddress[possessor][msg.sender] == true) {
                    found = true;
                }
            }
            require(found);
            // Now that the hashes are the same we can approve the lease
            bytes32 hashed_lease = _hashLease(_tokenId, _start, _end);
            approvalsbyLease[hashed_lease] = _addressTo;
            emit LeaseApproval(_addressTo, _tokenId, _start, _end);
        }
    }

    function _isApproved(
        address _addressTo,
        uint256 _tokenId,
        uint256 _start,
        uint256 _end
    ) internal view returns (bool) {
        if (
            approvalsbyLease[_hashLease(_tokenId, _start, _end)] == _addressTo
        ) {
            return true;
        }
        // if (ownerOf(_tokenId) == msg.sender) {
        //     return true;
        // }
        bool found = false;
        address _owner = ownerOf(_tokenId);
        if (msg.sender == _owner) {
            found = true;
        } else {
            if (approvalbyAddress[_owner][msg.sender] == true) {
                found = true;
            }
        }
        if (found) {
            return true;
        } else {}
        return false;
    }

    function _hashLease(
        // address _addressTo,
        uint256 _tokenId,
        uint256 _start,
        uint256 _end
    ) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_tokenId, _start, _end));
    }

    function getLeaseApproved(
        uint256 _tokenId,
        uint256 _start,
        uint256 _end
    ) external view override returns (address) {
        return approvalsbyLease[_hashLease(_tokenId, _start, _end)];
    }

    function setLeaseApprovalForAll(address _agent, bool _approved)
        external
        override
    {
        approvalbyAddress[msg.sender][_agent] = _approved;
        emit LeaseApprovalForAll(msg.sender, _agent, _approved);
    }

    function isLeaseApprovedForall(address _owner, address _agent)
        external
        view
        override
        returns (bool)
    {
        return approvalbyAddress[_owner][_agent];
    }
}
