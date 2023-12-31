// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

contract InsuranceCrypto {
    address insurer;
    address admin;
    uint96 protocolInsuredFee;

    struct Insurer {
        uint elapsedTime;
        uint lastClaimed;
        uint InsuredTimes;
    }

    mapping(address => Insurer) public insurers;
    mapping(address => bool) public insurerExist;

    constructor(address _insurer, uint96 _protocolInsuredFee) {
        insurer = _insurer;
        protocolInsuredFee = _protocolInsuredFee;
        insurerExist[_insurer] = true;
    }

    modifier onlyInsurer() {
        require(msg.sender == insurer, "Not Permitted");
        _;
    }

    error NotProtocolInsuredFee();
    error ZeroAmount();
    error InsufficientBal();
    error BiYearClaimMadeAlready();
    error EndOFMonthNotReached();
    error TooSoonToClaim();

    function insureMonthly() external payable {
        if (msg.value != protocolInsuredFee) {
            revert NotProtocolInsuredFee();
        }
        if (block.timestamp <= insurers[insurer].elapsedTime) {
            revert EndOFMonthNotReached();
        }
        insurers[insurer].elapsedTime = block.timestamp + 30 days;
        insurers[insurer].InsuredTimes++;
    }

    function claimInsuranceDividends(uint96 _value) external onlyInsurer {
        if (insurers[msg.sender].InsuredTimes < 2) {
            revert TooSoonToClaim();
        }
        if (insurers[msg.sender].lastClaimed >= block.timestamp + 182 days) {
            revert BiYearClaimMadeAlready();
        }
        insurers[insurer].InsuredTimes++;
        if (address(this).balance < _value) {
            revert InsufficientBal();
        }

        insurers[insurer].lastClaimed = block.timestamp;
        payable(msg.sender).transfer(_value);
    }

    function returnInsurerInfo()
        external
        view
        returns (
            uint elapsedTime,
            uint lastClaimed,
            uint InsuredTimes,
            uint balance
        )
    {
        elapsedTime = insurers[insurer].elapsedTime;
        lastClaimed = insurers[insurer].lastClaimed;
        InsuredTimes = insurers[insurer].elapsedTime;
        balance = address(this).balance;
    }

    receive() external payable {}
}
