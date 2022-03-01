//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface ITemporalNFT {
    event Borrow(
        uint256 indexed tokenId,
        address indexed borrower,
        uint256 start,
        uint256 end
    );
    event Return(
        uint256 indexed tokenId,
        address indexed borrower,
        uint256 start,
        uint256 end
    );
    event Mint(uint256 indexed tokenId, string tokenURI);

    function hasAccess(
        address _address,
        uint256 _tokenId,
        uint256 _block
    ) external view returns (bool);

    function borrow(uint256 _tokenId, uint256 _block)
        external
        view
        returns (address);

    function returnBy(uint256 _tokenId) external view returns (uint256);

    function lease(
        uint256 _tokenId,
        uint256 _start,
        uint256 _end
    ) external payable;

    function transfer(
        uint256 _tokenId,
        uint256 _start,
        uint256 _end,
        address _addressTo
    ) external payable;

    //emit borrow
    //emit return

    function approve(
        uint256 _tokenId,
        uint256 _start,
        uint256 _end,
        address _addressTo
    ) external;

    function transferFrom(
        uint256 tokenId,
        uint256 _start,
        uint256 _end,
        address _addressFrom
    ) external payable;

    //emit borrow
    //emit return

    function uri(uint256 _tokenId) external view returns (string memory);

    function hash(uint256 _tokenId) external view returns (uint256);

    function mint(string memory _tokenURI, uint256 hash) external;

    //emit mint

    function unlease(
        uint256 _tokenId,
        uint256 _start,
        uint256 _end
    ) external;
    //emit return
}
