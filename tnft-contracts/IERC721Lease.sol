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
    event LeaseApproval(
        address indexed _from,
        address indexed _to,
        uint256 indexed _tokenId,
        uint256 _start,
        uint256 _end
    );
    event LeaseApprovalForAll(
        address indexed _from,
        address indexed _operator,
        bool _approved
    );

    // event Mint(uint256 indexed tokenId, string tokenURI);

    function lesseeOf(uint256 _tokenId, uint256 _block)
        external
        view
        returns (address);

    function returnBy(uint256 _tokenId) external view returns (uint256);

    function approveLease(
        uint256 _tokenId,
        uint256 _start,
        uint256 _end,
        address _addressTo
    ) external;

    function leaseFrom(
        address _addressFrom,
        address _addressTo,
        uint256 tokenId,
        uint256 _start,
        uint256 _end
    ) external payable;

    function unlease(
        uint256 _tokenId,
        uint256 _start,
        uint256 _end
    ) external;
}
