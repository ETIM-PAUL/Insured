// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
import "./InsuredCrypto.sol";
import "./InsuredCollateral.sol";

contract InsuredFactory {
    mapping(address => bool) private _haveCreatedCrypto;
    mapping(address => bool) private _haveCreatedCollateral;

    address[] insuredCryptoAddresses;
    address[] insuredCollateralAddresses;

    address generalLoanToken;

    event InsuredCryptoInstance(
        address insurer,
        uint protocolInsuredFee,
        address insurance
    );
    event InsuredCollateralInstance(
        address insurer,
        uint desiredLoan,
        address insurance
    );

    enum InsuranceCollaterPolicy {
        AllLoan,
        PercentageLoan
    }

    constructor(address _generalLoanToken) {
        generalLoanToken = _generalLoanToken;
    }

    function createInsuredCrypto(
        uint96 protocolInsuredFee
    ) external returns (InsuranceCrypto _insuredCrypto) {
        require(_haveCreatedCrypto[msg.sender] == false, "Already Created");
        _insuredCrypto = new InsuranceCrypto(msg.sender, protocolInsuredFee);
        _haveCreatedCrypto[msg.sender] = true;
        insuredCryptoAddresses.push(address(_insuredCrypto));

        emit InsuredCryptoInstance(
            msg.sender,
            protocolInsuredFee,
            address(_insuredCrypto)
        );
    }

    function createInsuredCollateral(
        bool collateralPriceReduceType
    ) external payable returns (InsuredCollateral _insuredCollateralInstance) {
        require(_haveCreatedCrypto[msg.sender] == false, "Already Created");
        uint ethValue = (msg.value * 1800) / 10 ** 18;
        uint _LoanAmount = (ethValue * (1000 * 10 ** 18)) / 1800;

        _insuredCollateralInstance = new InsuredCollateral(
            msg.value,
            _LoanAmount,
            msg.sender,
            address(this),
            generalLoanToken,
            collateralPriceReduceType
        );
        _haveCreatedCollateral[msg.sender] = true;
        insuredCryptoAddresses.push(address(_insuredCollateralInstance));

        IERC20(generalLoanToken).transfer(msg.sender, _LoanAmount);
        payable(address(_insuredCollateralInstance)).transfer(msg.value);

        emit InsuredCryptoInstance(
            msg.sender,
            _LoanAmount,
            address(_insuredCollateralInstance)
        );
    }

    function getColateralPools()
        external
        pure
        returns (address[] memory colateralPoolAddresses)
    {
        return colateralPoolAddresses;
    }

    function getCryptoPools()
        external
        pure
        returns (address[] memory colateralPoolAddresses)
    {
        return colateralPoolAddresses;
    }
}
