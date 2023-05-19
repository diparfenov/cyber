// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

library Events {
    event Registration(address indexed memberAddress, string indexed memberName, uint indexed _atTime, uint _state);

    event BatchMint(address[] indexed addresses, uint indexed atTime);

    event ChangeTitle(uint indexed index, string indexed oldTitle, string indexed _newTitle, uint atTime);

    event ChangeCity(uint indexed index, string indexed oldCity, string indexed newCity, uint atTime);

    event ChangeDate(uint indexed index, uint indexed newStartsDate, uint indexed newEndsDate, uint atTime);
}
