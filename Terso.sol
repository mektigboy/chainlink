// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract CryptoIndexFund {
    AggregatorV3Interface internal priceFeedLINK;
    AggregatorV3Interface internal priceFeedSHIB;

    string public name;
    string public symbol;

    mapping(address => uint256) public balances;

    constructor(string memory _name, string memory _symbol, address _priceFeedLINK, address _priceFeedSHIB) {
        name = _name;
        symbol = _symbol;
        priceFeedLINK = AggregatorV3Interface(_priceFeedLINK);
        priceFeedSHIB = AggregatorV3Interface(_priceFeedSHIB);
    }

    function buy() public payable {
        uint256 totalValue = getTotalValue();
        uint256 shares = msg.value * 1e18 / totalValue;
        balances[msg.sender] += shares;
    }

    function sell(uint256 shares) public {
        uint256 totalValue = getTotalValue();
        uint256 payout = totalValue * shares / getTotalShares();
        balances[msg.sender] -= shares;
        payable(msg.sender).transfer(payout);
    }

    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }

    function getTotalShares() public view returns (uint256) {
        uint256 totalShares = 0;
        for (uint256 i = 0; i < balances.length; i++) {
            totalShares += balances[i];
        }
        return totalShares;
    }

    function getTotalValue() public view returns (uint256) {
        uint256 linkPrice = uint256(getLatestPriceLINK());
        uint256 shibPrice = uint256(getLatestPriceSHIB());
        return balances * (linkPrice + shibPrice) / 2;
    }

    function getLatestPriceLINK() public view returns (int256) {
        (, int256 price, , , ) = priceFeedLINK.latestRoundData();
        return price;
    }

    function getLatestPriceSHIB() public view returns (int256) {
        (, int256 price, , , ) = priceFeedSHIB.latestRoundData();
        return price;
    }
}
