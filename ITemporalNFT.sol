//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

interface ITemporalNFT {

event Borrow(uint indexed tokenId, address indexed borrower, uint start, uint end);
event Return(uint indexed tokenId, address indexed borrower, uint start, uint end);
event Mint(uint indexed tokenId, string tokenURI);


function hasAccess(address _address, uint _tokenId, uint _block) public view returns bool;

function borrower(uint _tokenId, uint _block) public view returns address;

function returnBy(uint _tokenId) public view returns uint;

function borrow(uint _tokenId, uint _start, uint _end) public payable;

function transfer(uint _tokenId, uint _start, uint _end, address _addressTo) public payable;
  //emit borrow
  //emit return

function approve(uint _tokenId, uint _start, uint _end, address _addressTo);


function transferFrom(uint tokenId, uint _start, uint _end, address _addressFrom) public payable;
  //emit borrow
  //emit return


function uri(uint _tokenId) public view returns string;


function hash(uint _tokenId) public view returns uint;


function mint(string _tokenURI, uint hash) public;
  //emit mint


function return(uint _tokenId, uint _start, uint _end) public;
  //emit return








  using SafeMath for uint256;

  event SubscriptionAdded(string serviceName, string timeFrame);
  event NewNFTMinted(address creator, uint tokenId);

  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  constructor() ERC721 ("Subscriber", "SUBSCRIBER") {

  }

  mapping (address => uint => uint) public recordTimestamp;

  struct Subscription {
    string serviceName;
    string timeFrame;
    uint rate;
    uint uniqueId;
    address creator;
  }

  //@dev create an array for NFTreferences
  Subscriptions[] public subscriptions;

  //@dev creates a reference for an NFT
  function addSubscription(string memory _serviceName, string memory _timeFrame, uint _rate) public {
    uint totalSubscriptions = subscriptions.length.add(1);
    references.push(Subscriptions(_serviceName, _timeFrame, _rate, totalNFTs, msg.sender));
    myNFTs[msg.sender].push(totalNFTs);
    emit RefCreated(_network, _contractAddress, _tokenId);
  }

  //@dev adds signature to NFT
  function subscribe(uint _subscriptionId) external {
    uint start = block.timestamp;
    uint expire =
    signatures[_grefId].push(msg.sender);
    emit Signed(msg.sender, _tokenId);
  }

  function mintNFT(uint _subscriptionId) public {
    _tokenIds.increment();
    uint256 newItemId = _tokenIds.current();

    _safeMint(msg.sender, newItemId);

    uint _name = subscriptions[_subscriptionId.sub(1)].name;
    uint _name = subscriptions[_subscriptionId.sub(1)].name;
    uint _name = subscriptions[_subscriptionId.sub(1)].name;

    string memory json = Base64.encode(
    bytes(
        string(
            abi.encodePacked(
              '{"name": "',
                // We set the title of our NFT as the generated word.
                _name,
                '", "description": "', _description, '", "image": "', _image,
                '"}'
            )
        )
    )
    );

    string memory finalTokenUri = string(
      abi.encodePacked("data:application/json;base64,", json)
  );

    // Update your URI!!!
    _setTokenURI(newItemId, finalTokenUri);

    emit NewNFTMinted(msg.sender, newItemId);

  }
}
