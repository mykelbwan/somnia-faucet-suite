// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

contract TestDrops {
    address public owner;

    error ClaimFail();
    error Unauthorized();
    error InvalidToken();

    constructor() {
        owner = msg.sender;
    }

    modifier Owner() {
        if (msg.sender != owner) revert Unauthorized();
        _;
    }

    receive() external payable {}

    function claimNative(address to, uint256 amount) external Owner {
        if (address(this).balance < amount) {
            (bool ok, ) = payable(to).call{value: address(this).balance}("");
            if (!ok) revert ClaimFail();
        }
        (bool ok, ) = payable(to).call{value: amount}("");
        if (!ok) revert ClaimFail();
    }

    function claimERC20(
        address token,
        address to,
        uint256 amount
    ) external Owner {
        IERC20 erc20 = IERC20(token);
        if (amount > erc20.balanceOf(address(this))) {
            // if requesting amount is greater than contract balance ? send the user remaining balance
            bool ok = erc20.transfer(to, erc20.balanceOf(token));
            if (!ok) revert ClaimFail();
        }
        bool ok = erc20.transfer(to, amount);
        if (!ok) revert ClaimFail();
    }

    function changeOwner(address newOwner) external Owner {
        owner = newOwner;
    }
}
