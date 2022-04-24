//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

/*  
this import is exactly as copy and paste the code in the chainlink github repository.
An interface defines a new type and compiles down to an ABI (Application Binary Interface).
The ABI tells solidity and other languages how it can interact with another contract.
*/
import "node_modules/@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract FundMe {
    // mapping of addresses and amount they send to this contract
    mapping(address => uint256) public addressToAmountFunded;
    // define the addresses of all the funders
    address[] public funders;
    // define an address to store the owner of the contract
    address public owner;
    // define a global public aggregatorv3interface
    AggregatorV3Interface public priceFeed;

    // define a constructor called to deploy the contract
    constructor(address _priceFeed) {
        owner = msg.sender;
        priceFeed = AggregatorV3Interface(_priceFeed);
    }

    // payable means that some value can be enclosed in this transaction (wei, gwei, ether, ..)
    function fund() public payable {
        // set a minimum of USD dollar that can be sent
        //uint256 minimumUSD = 50 * 10 ** 18;

        /*if( msg.value < minimumUSD ) {
            //revert
            revert??;
        }*/

        /*
        require statement verifies the truthness. In case it is not verified 
        it reverts the transacation, sending back the amount, the remaining gas and a message (not necessary)
        */
        //require( msg.value>=minimumUSD, "Minimum amount 50$" );
        //require( msg.value>=minimumUSD );

        // msg.sender msg.value are keywords to access the sender of the transaction
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }

    // when many functions requires for example msg.send==owner we can create a modifier
    modifier onlyOwner() {
        //_; can also be before the function if you want to run the modifier after the function
        require(msg.sender == owner);
        _;
    }

    /*unction withdraw() payable public {
        // this refers to the contract we are currently in
        // require the sender to be the owner of the contract
        require(msg.sender==owner);
        payable(msg.sender).transfer( address(this).balance );
    }*/

    // onlyOwner modifier ensures only the address of the owner can withdraw the money from the contract
    function withdraw() public payable onlyOwner {
        // this refers to the contract we are currently in
        payable(msg.sender).transfer(address(this).balance);

        // for loop to reset the funder shares to 0
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = address(funders[funderIndex]);

            addressToAmountFunded[funder] = 0;
        }
        // reinitialize the funders
        funders = new address[](0);
    }

    /*  
    if we want to convert the amount to USD (e.g.) we need to know
    the ETH/USD conversion rate. 
    **** Blockchain Oracles ****
    There exist Decentralized Oracles that allow not to break the decentralization of the blockchains
    while interacting with the real world 
    */

    // return the version of the interface
    function getVersion() public view returns (uint256) {
        return priceFeed.version();
    }

    // get entrance fee
    function getEntranceFee() public view returns (uint256) {
        uint256 minimumUSD = 50 * 10**18;
        uint256 price = getPrice();
        uint256 precision = 1 * 10**18;
        return (minimumUSD * precision) / price;
    }

    // return the price ETH/USD
    function getPrice() public view returns (uint256) {
        // tuple is a list of object of potentially different types whose number is a constant at compile-time
        // undesired returned variable can be removed by leaving their position empty
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        //return uint256(answer);
        return uint256(answer * 1000000000);
    }

    // convert the amount sent to USD
    function getConversionRates(uint256 ethAmount)
        public
        view
        returns (uint256)
    {
        // get the price of eth in usd
        uint256 ethPrice = getPrice();
        // convert the eth amount to usd
        // 622330000000000000000
        uint256 ethAmountInUSD = (ethPrice * ethAmount) / 10000000000000000;

        return ethAmountInUSD;
    }
}
