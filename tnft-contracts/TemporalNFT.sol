//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import './ITemporalNFT.sol';

contract TemporalNFT is ITemporalNFT {

event Borrow(uint indexed tokenId, address indexed borrower, uint start, uint end);
event Return(uint indexed tokenId, address indexed borrower, uint start, uint end);
event Mint(uint indexed tokenId, string tokenURI);

uint[] hashes;
string[] uris;
uint currentToken = 0;


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


function uri(uint _tokenId) public view returns string {
  return (uris[_tokenId]);
}


function hash(uint _tokenId) public view returns uint {
  return (hashes[_tokenId]);
}


function mint(string _tokenURI, uint _hash) public {
  hashes.push(_hash);
  uris.push(_tokenURI);
  emit Mint(currentToken, _tokenURI);
  currentToken++;
}
  //emit mint


function return(uint _tokenId, uint _start, uint _end) public;
  //emit return

}
