//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC721Lease {
    event Leased(
        uint256 indexed tokenId,
        address indexed borrower,
        uint256 start,
        uint256 end
    );
    event Returned(
        uint256 indexed tokenId,
        address indexed borrower,
        uint256 start,
        uint256 end
    );

    // event Mint(uint256 indexed tokenId, string tokenURI);

    function lesseeOf(uint256 _tokenId, uint256 _block)
        external
        view
        returns (address);

    function returnBy(uint256 _tokenId) external view returns (uint256);

    function lease(
        uint256 _tokenId,
        uint256 _start,
        uint256 _end
    ) external payable;

    // For a lease in period ABC, where you sublet period B, you would generate new lease events for A and C for you, and a return event for ABC for you, and a lease event for them for B
    //emit lease events (split in the original lease, and the new re-lease)
    //emit return (undo of rights by the original lessee)

    function approveRelease(
        uint256 _tokenId,
        uint256 _start,
        uint256 _end,
        address _addressTo
    ) external;

    function releaseFrom(
        address _addressFrom,
        address _addressTo,
        uint256 tokenId,
        uint256 _start,
        uint256 _end
    ) external payable;

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
    ) external;
    //emit return
}
