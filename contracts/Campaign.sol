pragma solidity ^0.4.22;

import {Ownable} from './Ownable.sol';
import {DateTime} from './DateTime.sol';
import {SpendBallot} from './SpendBallot.sol';

contract Campaign is Ownable, DateTime {

    event NewParticipant(address _address, uint _invested);
    event FinishCampaign(uint expectedToCollect, uint actualCollected);

    mapping(address => uint) private _participantsMap;
    address[] private _participantsList;

    uint public _hardCap;
    uint public _minInvest;
    address public _spendBallot;

    uint256 public _startTimestamp;
    uint256 public _endTimestamp;
    bool public finished = false;

    address self = address(this);

    constructor(uint hardCap, uint minInvest, uint16 endYear, uint8 endMonth, uint8 endDay) public {
        _hardCap = hardCap;
        _minInvest = minInvest;
        _startTimestamp = block.timestamp;
        _endTimestamp = toTimestamp(endYear, endMonth, endDay);
    }

    function setSpendBallot(address spendBallot) restricted public {
        require(_spendBallot == 0x0);
        _spendBallot = SpendBallot(spendBallot);
    }

    function participate() public payable {
        if (finished) {
            returnCurrentFund();
        } else if (now > _endTimestamp) {
            returnCurrentFund();
            finishCampaign();
        } else {
            require(msg.value >= _minInvest);
            if (_participantsMap[msg.sender] != 0) {
                _participantsMap[msg.sender] += msg.value;
            } else {
                _participantsMap[msg.sender] = msg.value;
                _participantsList.push(msg.sender);
            }
            emit NewParticipant(msg.sender, msg.value);
        }
    }

    function finishCampaign() private restricted {
        finished = true;
        emit FinishCampaign(_hardCap, self.balance);
        if (self.balance >= _hardCap) {
            _spendBallot.transfer(self.balance);
        } else {
            returnAllFunds();
        }
    }

    function participantsCount() view public returns (uint) {
        return _participantsList.length;
    }

    function participantInvested(address user) view public returns (uint) {
        return _participantsMap[user];
    }

    function returnCurrentFund() private {
        msg.sender.transfer(msg.value);
    }

    function returnAllFunds() private {
        for (uint i = 0; i < _participantsList.length; i++) {
            address participantAddress = _participantsList[i];
            uint participantInvestment = _participantsMap[participantAddress];
            participantAddress.transfer(participantInvestment);
        }
    }

}
