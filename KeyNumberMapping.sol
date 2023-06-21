// SPDX-License-Identifier: MIT 
pragma solidity 0.8.18;

// キーにする文字列とそれに対応した番号を管理する。
// - キーと番号は重複してはならない。
// - キーからも番号からもお互いを参照できる。
// - キーとして空文字は使えない。
// - 0番はuintの初期値なので使用できない。
// - キーの削除は出来ないが、キーに対応する番号は変更ができる。
library KeyNumberMapping {
    struct Map {
        mapping(string => uint) keyToNumber;
        mapping(uint => string) numberToKey;
        uint[] numbers;
        string[] keys;
    }

    function isValidKey(string memory key) private pure {
        require(bytes(key).length > 0,  "Key cannot be an empty string.");
    }

    function isValidNumber(uint number) private pure {
        require(number != 0, "Number cannot be zero.");
    }

    function add(Map storage map, string memory key, uint number) public {
        isValidKey(key);
        isValidNumber(number);
        require(map.keyToNumber[key] == 0, "Key already exists.");
        require(bytes(map.numberToKey[number]).length == 0, "Number already exists.");

        map.keyToNumber[key] = number;
        map.numberToKey[number] = key;
        map.keys.push(key);
        map.numbers.push(number);
    }

    function getNumber(Map storage map, string memory key) public view returns (uint) {
        return map.keyToNumber[key];
    }

    function getKey(Map storage map, uint number) public view returns (string memory) {
        return map.numberToKey[number];
    }

    function update(Map storage map, string memory key, uint number) public {
        isValidKey(key);
        isValidNumber(number);
        require(map.keyToNumber[key] != 0, "Key does not exist.");
        require(bytes(map.numberToKey[number]).length == 0, "Number already exists.");

        // Remove old mapping
        delete map.numberToKey[map.keyToNumber[key]];

        // Update to new mapping
        map.keyToNumber[key] = number;
        map.numberToKey[number] = key;
    }

    function getEntries(Map storage map, uint start, uint count) public view returns (string[] memory, uint[] memory) {
        require(start < map.keys.length, "Start index out of range.");
        
        uint end = start + count;
        if (end > map.keys.length) end = map.keys.length;
        
        string[] memory keysSlice = new string[](end - start);
        uint[] memory numbersSlice = new uint[](end - start);
        
        for (uint i = start; i < end; i++) {
            keysSlice[i - start] = map.keys[i];
            numbersSlice[i - start] = map.numbers[i];
        }
        
        return (keysSlice, numbersSlice);
    }

    function getSize(Map storage map) public view returns (uint) {
        return map.keys.length;
    }

}
