pragma solidity ^0.4.22;

contract Ownable {
    address private owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier restricted() {
        require(msg.sender == owner);
        _;
    }
}
