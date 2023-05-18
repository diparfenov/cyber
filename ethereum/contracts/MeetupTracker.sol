// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./Events.sol";
import "./Meetup.sol";

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
    mapping(address => uint) public donatesGlobal;
    mapping(uint => mapping(address => uint)) public donatesByAddress;

    modifier onlyOwnerV2(address _address) {
        require(owner() == _address, "You're not an owner!");
        _;
    }

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
            true,
            block.timestamp
        );

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

    function changeMeetupTitle(
        uint _index,
        string memory _newTitle,
        address _addressOwner
    ) external onlyOwnerV2(_addressOwner) {
        meetups[_index].title = _newTitle;
    }

    function closeMeetupByIndex(
        uint _index,
        address _addressOwner
    ) external onlyOwnerV2(_addressOwner) {
        bool isActiveNow = meetups[_index].isActive;
        require(isActiveNow, "Meetup already closed!");
        isActiveNow = false;

        emit Events.CloseMeetup(
            _index,
            meetups[_index].isActive,
            block.timestamp
        );
    }

    function withdraw(uint _amount) external onlyOwner {
        require(address(this).balance >= _amount, "Insufficient balance");
        payable(msg.sender).transfer(_amount);

        emit Events.Withdraw(_amount, msg.sender, block.timestamp);
    }

    function donate(uint _index, address _address) external payable {
        donatesByAddress[_index][_address] += msg.value;

        emit Events.Donate(
            _address,
            msg.value,
            _index,
            meetups[_index].title,
            block.timestamp
        );
    }

    function donateGlobal() external payable {
        donatesGlobal[msg.sender] = msg.value;

        emit Events.DonateGlobal(msg.sender, msg.value, block.timestamp);
    }

    function viewDonate(
        uint _index,
        address _address
    ) public view returns (uint) {
        return donatesByAddress[_index][_address];
    }

    function getMeetups() public view returns (Meetups[] memory) {
        return meetups;
    }

    function getMeetupByIndex(
        uint _index
    ) public view returns (Meetups memory) {
        return meetups[_index];
    }
}
