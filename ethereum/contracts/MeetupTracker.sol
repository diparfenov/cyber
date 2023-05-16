// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MeetupTracker is Ownable {
    struct Donate {
        address _address;
        uint _value;
    }

    struct Meetups {
        Meetup meetup;
        string title;
        uint index;
        bool isActive;
    }

    mapping(uint => Donate[]) donatesAll;
    mapping(uint => mapping(address => uint)) donatesByAddress;

    Meetups[] public meetups;
    uint currentIndex;

    event NewMeetupCreated(
        uint _meetupIndex,
        bool _isActive,
        address _meetupAddress,
        string _meetupTitle
    );

    // function donate(uint _index) external payable {
    //     uint currentMeetupDonate = meetups[_index].totalMeetupDonats;
    //     meetups[_index].donate[currentMeetupDonate][msg.sender] += msg.value;
    // }

    // function viewDonate(uint _index, address _address) public view  returns (uint) {
    //    return meetups[_index].donate[_address];

    // }

    function createMeetup(
        string memory _title,
        string memory _city,
        uint _startsDate,
        uint _endsDate
    ) public onlyOwner {
        Meetup newMeetupContract = new Meetup(
            msg.sender,
            _title,
            _city,
            currentIndex,
            _startsDate,
            _endsDate,
            true,
            this
        );

        Meetups memory newMeetup = Meetups(
            newMeetupContract,
            _title,
            currentIndex,
            true
        );

        meetups.push(newMeetup);

        emit NewMeetupCreated(
            currentIndex,
            meetups[currentIndex].isActive,
            address(newMeetupContract),
            _title
        );

        currentIndex++;
    }

    function deleteMeetup() public {}
}

contract Meetup is
    ERC721,
    ERC721Enumerable,
    ERC721URIStorage,
    ERC721Burnable,
    Ownable
{
    mapping(address => Member) public members;
    address[] public membersAddress;
    uint public registrations;
    uint public currentTokenId;

    MeetupTracker public tracker;

    string public title;
    string public city;
    uint public index;
    uint public startsDate;
    uint public endsDate;
    bool public isActive;

    struct Member {
        string memberName;
        string memberCompany;
        string memberRole;
        uint date;
        MemberState state;
    }

    enum MemberState {
        NotRegistred,
        Registered,
        CheckedAndGotNft
    }

    event Registration(
        address indexed _memberAddress,
        string indexed _memberName,
        uint indexed _time,
        MemberState _state
    );

    event CheckedAndGotNft(
        address indexed _memberAddress,
        uint indexed _time,
        MemberState _state
    );

    event BatchMint(address[] indexed _addresses);

    constructor(
        address _owner,
        string memory _title,
        string memory _city,
        uint _index,
        uint _startsDate,
        uint _endsDate,
        bool _isActive,
        MeetupTracker _tracker
    ) ERC721("MyToken", "MTK") {
        transferOwnership(_owner);
        title = _title;
        city = _city;
        index = _index;
        startsDate = _startsDate;
        endsDate = _endsDate;
        isActive = _isActive;
        tracker = _tracker;
    }

    function reg(
        string memory _name,
        string memory _company,
        string memory _role
    ) public {
        require(
            members[msg.sender].state == MemberState.NotRegistred,
            "You're already registred!"
        );
        require(block.timestamp < startsDate, "Registration has already ended");
        require(isActive, "Meetup has already ended");

        Member memory newMember = Member(
            _name,
            _company,
            _role,
            block.timestamp,
            MemberState.Registered
        );

        members[msg.sender] = newMember;
        membersAddress.push(msg.sender);

        registrations++;

        emit Registration(
            msg.sender,
            _name,
            block.timestamp,
            MemberState.Registered
        );
    }

    function verify(address _addr) public view returns (bool) {
        return (members[_addr].state == MemberState.Registered);
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

    function safeBatchMint(
        address[] memory addresses,
        string calldata tokenId
    ) public onlyOwner {
        //uint[] memory tokenIds = new uint[]()
        for (uint i = 0; i < addresses.length; i++) {
            address addr = addresses[i];
            if (members[addr].state == MemberState.Registered) {
                safeMint(addr, tokenId);
                members[addr].state = MemberState.CheckedAndGotNft;
            }
        }

        emit BatchMint(addresses);
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

//1684587790
//1684760590

// ["0x5B38Da6a701c568545dCfcB03FcB875f56beddC4",
// "0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2",
// "0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db",
// "0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB"]
