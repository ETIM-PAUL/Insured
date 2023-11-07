// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {Test, console2, stdError} from "forge-std/Test.sol";
import {InsuredFactory} from "../src/InsuredFactory.sol";
import {InsuranceCrypto} from "../src/InsuredCrypto.sol";
import {InsuredCollateral} from "../src/InsuredCollateral.sol";
import {USDC} from "../src/USDC.sol";

contract CounterTest is Test {
    InsuredFactory public insuredFactory;
    USDC public _usdc;

    InsuranceCrypto _insuredCrypto;
    InsuredCollateral _insuredCollateral;

    address _insurer = address(0x11);

    function setUp() public {
        _usdc = new USDC();
        insuredFactory = new InsuredFactory(address(_usdc));
        _usdc.mint(_insurer, 10000000000000000000000);
        // counter.setNumber(0);
    }

    function test_InsuredCryto() public {
        uint96 protocolInsuredFee = 0.1 ether;
        vm.deal(_insurer, 1 ether);
        vm.startPrank(_insurer);
        _insuredCrypto = insuredFactory.createInsuredCrypto(protocolInsuredFee);
        _insuredCrypto.insureMonthly{value: 0.1 ether}();
        vm.warp(32 days);
        _insuredCrypto.insureMonthly{value: 0.1 ether}();
        assertEq(address(_insuredCrypto).balance, 0.2 ether);
        _insuredCrypto.claimInsuranceDividends(0.2 ether);
        vm.stopPrank();
    }

    function test_InsuredCollateral() public {
        vm.deal(_insurer, 1 ether);
        _usdc.mint(address(insuredFactory), 10000000000000000000000);
        vm.startPrank(_insurer);
        _insuredCollateral = insuredFactory.createInsuredCollateral{
            value: 0.1 ether
        }(false);

        _usdc.approve(address(_insuredCollateral), 10000000000000000000000);
        _insuredCollateral.repayLoan(100000000000000000000);
    }
}
