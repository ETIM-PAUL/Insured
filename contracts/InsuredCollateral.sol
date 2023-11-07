// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "./IERC20.sol";

contract InsuredCollateral {
    address insuredFactory;
    address public insurer;
    address loanTokenAddress;
    uint256 public collateralAmount;
    uint256 public loanAmount;
    bool loanRepayed;
    uint256 public lastCollateralPercentCheckTimestamp;
    bool collateralDropPercentType;

    error InvalidRepaymentAmount();
    error LoanPaidBackAlready();
    error NotPermitted();

    event LoanPayed(address insurer, uint amount);

    constructor(
        uint256 _collateralAmount,
        uint256 _loanAmount,
        address _insurer,
        address _insuredFactory,
        address _loanTokenAddress,
        bool _collateralDropPercentType
    ) {
        insurer = _insurer;
        collateralAmount = _collateralAmount;
        loanAmount = _loanAmount;
        insuredFactory = _insuredFactory;
        loanTokenAddress = _loanTokenAddress;
        collateralDropPercentType = _collateralDropPercentType;
    }

    function repayLoan(uint _repayment) external {
        if (loanAmount < _repayment || loanAmount > _repayment) {
            revert InvalidRepaymentAmount();
        }
        if (loanRepayed == false) {
            revert LoanPaidBackAlready();
        }
        if (collateralDropPercentType == true) {
            if (hasCollateralPriceDroppedByTenPercent(getCurrentEthPrice())) {
                loanAmount -= _repayment;
                loanRepayed = true;
                IERC20(loanTokenAddress).transferFrom(
                    msg.sender,
                    insuredFactory,
                    getTenPercentRepayment()
                );
                payable(insurer).transfer(collateralAmount);
            } else {
                loanAmount -= _repayment;
                loanRepayed = true;
                IERC20(loanTokenAddress).transferFrom(
                    msg.sender,
                    insuredFactory,
                    _repayment
                );
                payable(insurer).transfer(collateralAmount);
            }
        } else {
            loanAmount -= _repayment;
            loanRepayed = true;
            IERC20(loanTokenAddress).transferFrom(
                msg.sender,
                insuredFactory,
                _repayment
            );
            payable(insurer).transfer(collateralAmount);
        }

        emit LoanPayed(msg.sender, _repayment);
    }

    function getCurrentEthPrice() internal pure returns (uint) {
        return 1800;
    }

    function getTenPercentRepayment()
        internal
        view
        returns (uint tenPercentOff)
    {
        if (
            collateralDropPercentType == true &&
            block.timestamp >= lastCollateralPercentCheckTimestamp + 30 days
        ) {
            tenPercentOff = ((loanAmount * 10) / 100);
        } else {
            revert NotPermitted();
        }
    }

    function hasCollateralPriceDroppedByTenPercent(
        uint256 currentPrice
    ) public returns (bool) {
        require(
            lastCollateralPercentCheckTimestamp < block.timestamp - 30 days,
            "Only monthly checked"
        );
        uint initialCollateralPrice = (loanAmount * getCurrentEthPrice()) /
            (1000 * 10 ** 18);
        uint256 priceDropPercentage = ((initialCollateralPrice - currentPrice) *
            100) / initialCollateralPrice;

        lastCollateralPercentCheckTimestamp = block.timestamp;
        return priceDropPercentage >= 10;
    }

    receive() external payable {}
}
