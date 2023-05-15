// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./MeetupTracker.sol";

contract MyToken is
    ERC721,
    ERC721Enumerable,
    ERC721URIStorage,
    ERC721Burnable,
    Ownable
{
    MeetupTracker tracker;
    uint public currentTokenId;

    string public title;
    string public city;
    uint public index;
    uint public startsDate;
    uint public endsDate;

    enum MembertState {
        Registered,
        CheckedIn,
        GotNft
    }

    struct Member {
        string name;
        string companyOrProject;
        string positionOrRole;
        MembertState state;
    }

    Member[] public members;

    constructor(
        string memory _title,
        string memory _city,
        uint _index,
        uint _startsDate,
        uint _endsDate,
        MeetupTracker _tracker
    ) ERC721("MyToken", "MTK") {
        title = _title;
        city = _city;
        index = _index;
        startsDate = _startsDate;
        endsDate = _endsDate;
        tracker = _tracker;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "";
    }

    function safeMint(address to, string calldata tokenId) public onlyOwner {
        _safeMint(to, currentTokenId);
        //сопоставляем tokenURI и tokenId
        _setTokenURI(currentTokenId, tokenId);
        currentTokenId++;
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function _burn(
        uint256 tokenId
    ) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
