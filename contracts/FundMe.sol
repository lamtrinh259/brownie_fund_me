// SPDX-License-Identifier: MIT

pragma solidity ^0.6.6;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

contract FundMe {
    // "using" allows to use a library for whatever purpose
    // using A for B;

    mapping(address => uint256) public addressToAmountFunded;
    address public owner;

    // Addresses of all the funders
    address[] public funders;

    AggregatorV3Interface public priceFeed;

    // this function will be called the moment the contract is deployed
    constructor(address _priceFeed) public {
        priceFeed = AggregatorV3Interface(_priceFeed);
        owner = msg.sender; // whoever deploys this smart contract
    }

    function fund() public payable {
        // set a threshold in USD: $50
        // msg.sender and msg.value are values for every call function
        uint256 minimumUSD = 50 * 10**18;
        // if the amount is smaller than minimum, the transaction will be reverted
        require(
            getConversionRate(msg.value) >= minimumUSD,
            "You need to spend more than $50 of ETH!"
        );
        addressToAmountFunded[msg.sender] += msg.value;
        // Get the ETH -> USD conversion rate using oracle
        funders.push(msg.sender);
    }

    function getVersion() public view returns (uint256) {
        return priceFeed.version();
    }

    function getPrice() public view returns (uint256) {
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        return uint256(answer * 10000000000);
    }

    function getConversionRate(uint256 ethAmount)
        public
        view
        returns (uint256)
    {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUSD = (ethPrice * ethAmount) / 100000000;
        return ethAmountInUSD;
        // 1920642442180000000000
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can withdraw the balance");
        _;
    }

    function withdraw() public payable onlyOwner {
        // "this" refers to the contract we're currently in
        // Need the payable before msg.sender or it'll throw an error
        payable(msg.sender).transfer(address(this).balance);
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
    }

    function getEntranceFee() public view returns (uint256) {
        // minimum USD
        uint256 minimumUSD = 50 * 10**8;
        uint256 price = getPrice();
        uint256 precision = 1 * 10**8;
        return ((minimumUSD * precision) / price) + 1;
    }
}

// Smart contract that lets anyone deposit ETH into the contract
// Only the owner of the contract can withdraw the ETH
// pragma solidity >=0.6.6 <0.9.0;

// // Get the latest ETH/USD price from chainlink price feed
// import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
// import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

// contract FundMe {
//     // safe math library check uint256 for integer overflows
//     using SafeMathChainlink for uint256;

//     //mapping to store which address depositeded how much ETH
//     mapping(address => uint256) public addressToAmountFunded;
//     // array of addresses who deposited
//     address[] public funders;
//     //address of the owner (who deployed the contract)
//     address public owner;

//     // the first person to deploy the contract is
//     // the owner
//     constructor() public {
//         owner = msg.sender;
//     }

//     function fund() public payable {
//         // 18 digit number to be compared with donated amount
//         uint256 minimumUSD = 50 * 10**18;
//         //is the donated amount less than 50USD?
//         require(
//             getConversionRate(msg.value) >= minimumUSD,
//             "You need to spend more ETH!"
//         );
//         //if not, add to mapping and funders array
//         addressToAmountFunded[msg.sender] += msg.value;
//         funders.push(msg.sender);
//     }

//     //function to get the version of the chainlink pricefeed
//     function getVersion() public view returns (uint256) {
//         AggregatorV3Interface priceFeed = AggregatorV3Interface(
//             0x8A753747A1Fa494EC906cE90E9f37563A8AF630e
//         );
//         return priceFeed.version();
//     }

//     function getPrice() public view returns (uint256) {
//         AggregatorV3Interface priceFeed = AggregatorV3Interface(
//             0x8A753747A1Fa494EC906cE90E9f37563A8AF630e
//         );
//         (, int256 answer, , , ) = priceFeed.latestRoundData();
//         // ETH/USD rate in 18 digit
//         return uint256(answer * 10000000000);
//     }

//     // 1000000000
//     function getConversionRate(uint256 ethAmount)
//         public
//         view
//         returns (uint256)
//     {
//         uint256 ethPrice = getPrice();
//         uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1000000000000000000;
//         // the actual ETH/USD conversation rate, after adjusting the extra 0s.
//         return ethAmountInUsd;
//     }

//     //modifier: https://medium.com/coinmonks/solidity-tutorial-all-about-modifiers-a86cf81c14cb
//     modifier onlyOwner() {
//         //is the message sender owner of the contract?
//         require(msg.sender == owner);

//         _;
//     }

//     // onlyOwner modifer will first check the condition inside it
//     // and
//     // if true, withdraw function will be executed
//     function withdraw() public payable onlyOwner {
//         // If you are using Solidity version v0.8.0 or above,
//         // you will need to modify the code below to
//         // payable(msg.sender).transfer(address(this).balance);
//         msg.sender.transfer(address(this).balance);

//         //iterate through all the mappings and make them 0
//         //since all the deposited amount has been withdrawn
//         for (
//             uint256 funderIndex = 0;
//             funderIndex < funders.length;
//             funderIndex++
//         ) {
//             address funder = funders[funderIndex];
//             addressToAmountFunded[funder] = 0;
//         }
//         //funders array will be initialized to 0
//         funders = new address[](0);
//     }
// }
