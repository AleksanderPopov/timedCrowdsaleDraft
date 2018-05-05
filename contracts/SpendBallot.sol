pragma solidity ^0.4.22;

import {Campaign} from './Campaign.sol';
import {Ownable} from './Ownable.sol';


contract SpendBallot is Ownable {

    struct Request {
        address _spendAddress;
        uint _amount;
        mapping(address => bool) _voted;
        uint _approves;
        uint _disapproves;
        bool _finished;
    }

    Campaign private _campaign;
    Request[] public _requests;

    modifier voterOnly() {
        require(isVoter(msg.sender));
        _;
    }

    event RequestCreated(address _spendAddress, uint _amount);
    event RequestExecuted(address _spendAddress, uint _amount, uint _approves, uint _disapproves);
    event NewRequestVote(uint _index, address _voter, bool _approve);

    function setCampaign(address campaign) restricted public {
        require(address(_campaign) == 0x0);
        _campaign = Campaign(campaign);
    }

    function createRequest(address spendAddress, uint amount) restricted public {
        require(spendAddress != 0x0);
        require(amount > 0);

        Request memory newRequest;
        newRequest._spendAddress = spendAddress;
        newRequest._amount = amount;
        newRequest._approves = 0;
        newRequest._disapproves = 0;
        newRequest._finished = false;
        _requests.push(newRequest);

        emit RequestCreated(spendAddress, amount);
    }

    function executeRequest(uint index) restricted public {
        Request memory request = _requests[index];
        require(!request._finished);
        require(request._approves >= requiredMinOfVoters());

        request._spendAddress.transfer(request._amount);
        request._finished = true;

        emit RequestExecuted(request._spendAddress, request._amount, request._approves, request._disapproves);
    }

    function voteForRequest(uint index, bool approve) voterOnly public {
        require(!_requests[index]._finished);
        require(!_requests[index]._voted[msg.sender]);

        if (approve) {
            _requests[index]._approves++;
        } else {
            _requests[index]._disapproves++;
        }
        _requests[index]._voted[msg.sender] = true;

        emit NewRequestVote(index, msg.sender, approve);
    }

    function requiredMinOfVoters() private view returns (uint) {
        uint votersCount = _campaign.participantsCount();
        return votersCount / 2 + votersCount % 2;
    }

    function isVoter(address user) private view returns (bool) {
        return _campaign.participantInvested(user) != 0;
    }

}
