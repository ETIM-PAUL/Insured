// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "./InsuredCrypto.sol";

// import "./InsuredCollateral.sol";

contract InsuredFactory {
    /**
     * @dev STATE VARIABLE
     */

    mapping(address => bool) private _haveCreatedCrypto;
    mapping(address => bool) private _haveCreatedCollateral;

    address[] insuredCryptoAddresses;

    event InsuredCryptoInstance(
        address insurer,
        uint protocolInsuredFee,
        address insurance
    );

    constructor() {}

    function createInsuredCrypto(uint protocolInsuredFee) external {
        require(_haveCreatedCrypto[msg.sender] == false, "Already Created");
        InsuranceCrypto _insuredCrypto = new InsuranceCrypto(
            msg.sender,
            protocolInsuredFee
        );
        _haveCreatedCrypto[msg.sender] = true;
        insuredCryptoAddresses.push(address(_insuredCrypto));

        emit InsuredCryptoInstance(
            msg.sender,
            protocolInsuredFee,
            address(_insuredCrypto)
        );
    }
}
