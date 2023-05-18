// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

library Events {
    event MeetupCreated(
        uint indexed _meetupIndex,
        bool _isActive,
        address indexed _meetupAddress,
        string indexed _meetupTitle,
        uint _atTime
    );

    event CloseMeetup(
        uint indexed _index, 
        bool indexed _isActive,
        uint _atTime
    );

    event Donate(
        address indexed _address,
        uint indexed _value,
        uint indexed _meetupIndex,
        string _meetupTitle,
        uint _atTime
    );

    event DonateGlobal(
        address indexed _address,
        uint indexed _value,
        uint indexed _atTime
    );  

    event Withdraw(
        uint indexed _amount, 
        address indexed _address,
        uint indexed _atTime
    );

    event Registration (
        address indexed _memberAddress,
        string indexed _memberName,
        uint indexed _atTime,
        uint _state         
    );

    event BatchMint (
        address[] indexed _addresses,
        uint indexed _atTime          
    );

    event ChangeTitle(
        uint indexed _index, 
        string indexed _oldTitle,
        string indexed _newTitle,
        uint _atTime
    );

    event ChangeCity(
        uint indexed _index, 
        string indexed _oldCity,
        string indexed _newCity,
        uint  _atTime
    );

    event ChangeDate(
        uint indexed _index, 
        uint indexed _newStartsDate,
        uint indexed _newEndsDate,
        uint  _atTime
    );
}

contract MeetupTracker is Ownable {
    
    struct Meetups {
        Meetup meetup;
        string title;
        uint index;
        bool isActive;  
        uint timeCreated;    
    }

    Meetups[] public meetups;
    uint public currentIndex;
    mapping (address => uint) public donatesGlobal;
    mapping(uint => mapping(address => uint)) public donatesByAddress;

    modifier onlyOwnerV2(address _address) {
        require(owner() == _address, "You're not an owner!");
        _;
    }

    function createMeetup(string memory _title, string memory _city, uint _startsDate, uint _endsDate) public onlyOwner {

        Meetup newMeetupContract = new Meetup(msg.sender, _title, _city, currentIndex, _startsDate, _endsDate, true, this);

        Meetups memory newMeetup = Meetups(newMeetupContract, _title, currentIndex, true, block.timestamp);

        meetups.push(newMeetup);

        emit Events.MeetupCreated(
            currentIndex,
            meetups[currentIndex].isActive,
            address(newMeetupContract),
            _title,
            block.timestamp
        );

        currentIndex++;
    } 

    function changeMeetupTitle(uint _index, string memory _newTitle, address _addressOwner) external onlyOwnerV2(_addressOwner) {
        meetups[_index].title = _newTitle;
    }

    function closeMeetupByIndex(uint _index, address _addressOwner) external onlyOwnerV2(_addressOwner) {
        bool isActiveNow = meetups[_index].isActive;
        require(isActiveNow, "Meetup already closed!");
        isActiveNow = false;
        
        emit Events.CloseMeetup(_index, meetups[_index].isActive, block.timestamp);
    }

    function withdraw(uint _amount) external onlyOwner {
        require(address(this).balance >= _amount, "Insufficient balance");
        payable(msg.sender).transfer(_amount);

        emit Events.Withdraw(_amount, msg.sender, block.timestamp);
    }

    function donate(uint _index, address _address) external payable {
        donatesByAddress[_index][_address] += msg.value;

        emit Events.Donate(_address, msg.value, _index, meetups[_index].title, block.timestamp);
    }

    function donateGlobal() external payable {
        donatesGlobal[msg.sender] = msg.value;

        emit Events.DonateGlobal(msg.sender, msg.value, block.timestamp);
    }

    function viewDonate(uint _index, address _address) public view  returns (uint) {
       return donatesByAddress[_index][_address];
    }

    function getMeetups() public view returns(Meetups[] memory) {
        return meetups;
    }

    function getMeetupByIndex(uint _index) public view returns(Meetups memory) {
        return meetups[_index];
    }
}

contract Meetup is
    ERC721,
    ERC721Enumerable,
    ERC721URIStorage,
    ERC721Burnable,
    Ownable
{
    string public title;
    string public city; //
    uint public index;
    uint public startsDate; //
    uint public endsDate; //
    bool public isActive; 

    uint public registrations;
    uint public currentTokenId;

    mapping (address => Member) public members;
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

    function doDonate() external payable {
        require(msg.value > 0, "Donation can't be less than zero");
        tracker.donate{value: msg.value}(index, msg.sender);
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
        require(members[msg.sender].state == MemberState.NotRegistred, "You're already registred!" );     

        Member memory newMember = Member(_name, _company, _role, block.timestamp, MemberState.Registered);
       
        members[msg.sender] = newMember;
        membersAddress.push(msg.sender);

        registrations++;

        emit Events.Registration(msg.sender, _name, block.timestamp,uint(MemberState.Registered));
    }

    function reg(string memory _name) public {
        require(isActive, "Meetup has already ended");
        require(block.timestamp < startsDate, "Registration has already ended");
        require(members[msg.sender].state == MemberState.NotRegistred, "You're already registred!" );     

        Member memory newMember = Member(_name, "", "", block.timestamp, MemberState.Registered);
       
        members[msg.sender] = newMember;
        membersAddress.push(msg.sender);

        registrations++;

        emit Events.Registration(msg.sender, _name, block.timestamp,uint(MemberState.Registered));
    }

    function regWithCompany(string memory _name, string memory _company) public {
        require(isActive, "Meetup has already ended");
        require(block.timestamp < startsDate, "Registration has already ended");
        require(members[msg.sender].state == MemberState.NotRegistred, "You're already registred!" );     

        Member memory newMember = Member(_name, _company, "", block.timestamp, MemberState.Registered);
       
        members[msg.sender] = newMember;
        membersAddress.push(msg.sender);

        registrations++;

        emit Events.Registration(msg.sender, _name, block.timestamp,uint(MemberState.Registered));
    }

    function regWithRole(string memory _name, string memory _role) public {
        require(isActive, "Meetup has already ended");
        require(block.timestamp < startsDate, "Registration has already ended");
        require(members[msg.sender].state == MemberState.NotRegistred, "You're already registred!" );     

        Member memory newMember = Member(_name, "", _role, block.timestamp, MemberState.Registered);
       
        members[msg.sender] = newMember;
        membersAddress.push(msg.sender);

        registrations++;

        emit Events.Registration(msg.sender, _name, block.timestamp,uint(MemberState.Registered));
    }

    function changeTitle(string memory _newTitle) public onlyOwner {
        emit Events.ChangeTitle(index, title, _newTitle,block.timestamp);

        title = _newTitle;
        tracker.changeMeetupTitle(index, _newTitle, msg.sender);
    }

    function changeCity(string memory _newCity) public onlyOwner {
        emit Events.ChangeCity(index, city, _newCity,block.timestamp);

        city = _newCity;
    }

    function changeDate(uint _newStartsDate, uint _newEndsDate) public onlyOwner {
        startsDate = _newStartsDate;
        endsDate = _newEndsDate;
        
        emit Events.ChangeDate(index, _newStartsDate, _newEndsDate,block.timestamp);
    }

    function verify(address _addr) public view returns(bool) {
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
    function safeBatchMintAndCloseMeetup(address[] memory addresses, string calldata tokenId) public onlyOwner {
        require(isActive, "Meetup is closed!");
        for(uint i = 0; i < addresses.length; i++) {
            address addr = addresses[i];
            if(members[addr].state == MemberState.Registered) {
                safeMint(addr, tokenId);  
            }
        }

        emit Events.BatchMint (addresses, block.timestamp);

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
