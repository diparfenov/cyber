// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./MeetupTracker.sol";

contract Meetup {
    string public title;
    string public city;
    uint public index;
    uint public date;
    MeetupTracker tracker;

    constructor(
        string memory _title,
        string memory _city,
        uint _index,
        uint _date,
        MeetupTracker _tracker
    ) {
        title = _title;
        city = _city;
        index = _index;
        date = _date;
        tracker = _tracker;
    }

    receive() external payable {
        (bool success, ) = address(tracker).call{value: msg.value}(
            abi.encodeWithSignature("triggerPayment(uint256)", index)
        );
    }
}
