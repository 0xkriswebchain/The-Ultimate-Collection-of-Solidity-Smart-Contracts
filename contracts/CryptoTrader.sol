// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// You are a cryptocurrency trader with accounts on multiple exchanges.
//  The funds in each exchange are represented by the walletBalances array,
// and the fees associated with transferring funds between exchanges are represented by the networkFeesarray.

// Here's an example of how the process works:

// You start at Exchange 0, which has a balance of $5 (walletBalances[0] = 5).
// To transfer funds to Exchange 1, it costs $3 (networkFees[0] = 3).
// You send the $5 to Exchange 1, and $3 is deducted as a fee.
// So, the balance at Exchange 1 is increased by $2 (the $5 you transferred minus the $3 fee).

// This process continues in a clockwise direction, from one exchange to the next.
// The goal is to determine if you can complete a full round and end up at the same exchange where you started
// while consolidating all your funds.

// Return the starting exchange's index if you can complete the circuit once,
// consolidating all the funds into your account. If not possible, return -1. If a solution exists,
// it is guaranteed to be unique.

contract CryptoTrader {
    // This function is given walletBalances and networkFees array as input ,
    // it returns the index according to the above criteria if round trip possible else returns -1.
    function roundTrip(int256[] memory walletBalances, int256[] memory networkFees) public pure returns (int256) {
        int256 totalBalance = 0;
        int256 totalFees = 0;
        int256 currentBalance = 0;
        int256 startIndex = 0;

        for (uint256 i = 0; i < walletBalances.length; i++) {
            totalBalance += walletBalances[i];
            totalFees += networkFees[i];
            currentBalance += walletBalances[i] - networkFees[i];

            if (currentBalance < 0) {
                currentBalance = 0;
                startIndex = int256(i) + 1;
            }
        }

        if (totalBalance >= totalFees) {
            return startIndex;
        } else {
            return -1;
        }
    }
}
