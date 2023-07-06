// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";

import "./MeetupTracker.sol";

contract Meetup is ERC721, ERC721Enumerable, ERC721URIStorage, ERC721Burnable, Ownable {
    string public title;
    string public city;
    uint public index;
    uint public startsDate;
    uint public endsDate;
    bool public isActive;

    uint public registrations;
    uint public currentTokenId;

    mapping(address => Member) public members;
    address[] public membersAddress;
    MeetupTracker public tracker;

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
        address indexed memberAddress,
        string indexed memberName,
        uint indexed _atTime,
        uint _state
    );

    event BatchMint(address[] indexed addresses, uint indexed atTime);

    event ChangeTitle(
        uint indexed index,
        string indexed oldTitle,
        string indexed _newTitle,
        uint atTime
    );

    event ChangeCity(
        uint indexed index,
        string indexed oldCity,
        string indexed newCity,
        uint atTime
    );

    event ChangeDate(
        uint indexed index,
        uint indexed newStartsDate,
        uint indexed newEndsDate,
        uint atTime
    );

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
        tracker = MeetupTracker(_tracker);
    }

    function doDonate(uint _value) public payable {
        require(_value > 0, "Donation can't be less than zero");
        tracker.donate{value: _value}(index, msg.sender);
    }

    function closeMeetup() public onlyOwner {
        require(endsDate < block.timestamp, "Meetup is not over yet!");
        require(isActive, "Meetup already closed!");
        isActive = false;
        tracker.closeMeetupByIndex(index, msg.sender);
    }

    function reg(string memory _name, string memory _company, string memory _role) public {
        require(isActive, "Meetup has already ended");
        require(block.timestamp < startsDate, "Registration has already ended");
        require(members[msg.sender].state == MemberState.NotRegistred, "You're already registred!");

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

        emit Registration(msg.sender, _name, block.timestamp, uint(MemberState.Registered));
    }

    function reg(string memory _name) public {
        require(isActive, "Meetup has already ended");
        require(block.timestamp < startsDate, "Registration has already ended");
        require(members[msg.sender].state == MemberState.NotRegistred, "You're already registred!");

        Member memory newMember = Member(_name, "", "", block.timestamp, MemberState.Registered);

        members[msg.sender] = newMember;
        membersAddress.push(msg.sender);

        registrations++;

        emit Registration(msg.sender, _name, block.timestamp, uint(MemberState.Registered));
    }

    function regWithCompany(string memory _name, string memory _company) public {
        require(isActive, "Meetup has already ended");
        require(block.timestamp < startsDate, "Registration has already ended");
        require(members[msg.sender].state == MemberState.NotRegistred, "You're already registred!");

        Member memory newMember = Member(
            _name,
            _company,
            "",
            block.timestamp,
            MemberState.Registered
        );

        members[msg.sender] = newMember;
        membersAddress.push(msg.sender);

        registrations++;

        emit Registration(msg.sender, _name, block.timestamp, uint(MemberState.Registered));
    }

    function regWithRole(string memory _name, string memory _role) public {
        require(isActive, "Meetup has already ended");
        require(block.timestamp < startsDate, "Registration has already ended");
        require(members[msg.sender].state == MemberState.NotRegistred, "You're already registred!");

        Member memory newMember = Member(_name, "", _role, block.timestamp, MemberState.Registered);

        members[msg.sender] = newMember;
        membersAddress.push(msg.sender);

        registrations++;

        emit Registration(msg.sender, _name, block.timestamp, uint(MemberState.Registered));
    }

    function changeTitle(string memory _newTitle) public onlyOwner {
        emit ChangeTitle(index, title, _newTitle, block.timestamp);

        title = _newTitle;
        tracker.changeMeetupTitle(index, _newTitle, msg.sender);
    }

    function changeCity(string memory _newCity) public onlyOwner {
        emit ChangeCity(index, city, _newCity, block.timestamp);

        city = _newCity;
    }

    function changeDate(uint _newStartsDate, uint _newEndsDate) public onlyOwner {
        startsDate = _newStartsDate;
        endsDate = _newEndsDate;

        emit ChangeDate(index, _newStartsDate, _newEndsDate, block.timestamp);
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
        members[to].state = MemberState.CheckedAndGotNft;
        currentTokenId++;
    }

    function safeBatchMintAndCloseMeetup(
        address[] memory addresses,
        string calldata tokenId
    ) public onlyOwner {
        require(isActive, "Meetup is closed!");
        for (uint i = 0; i < addresses.length; i++) {
            address addr = addresses[i];
            if (members[addr].state == MemberState.Registered) {
                safeMint(addr, tokenId);
            }
        }

        emit BatchMint(addresses, block.timestamp);

        closeMeetup();
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

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
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

    receive() external payable {
        doDonate(msg.value);
    }
}
