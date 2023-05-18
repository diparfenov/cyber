// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

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

    event Registration(
        address indexed _memberAddress,
        string indexed _memberName,
        uint indexed _atTime,
        uint _state
    );

    event BatchMint(address[] indexed _addresses, uint indexed _atTime);

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
        uint _atTime
    );

    event ChangeDate(
        uint indexed _index,
        uint indexed _newStartsDate,
        uint indexed _newEndsDate,
        uint _atTime
    );
}
