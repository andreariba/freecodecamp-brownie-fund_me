from brownie import FundMe, MockV3Aggregator, network, config

from scripts.utility import get_account, deploy_mock, LOCAL_BLOCKCHAIN_ENVIRONMENTS

from web3 import Web3


# since we do not have @chainlink contracts
# on the local ganache chain we have to create a mock interface


def deploy_fund_me():

    # network
    print("[Network]:", network.show_active())

    account = get_account()
    print("[Account used]:", account)

    # after updating the FundMe we have to pass pricefeed address to deploy FundMe
    # if we are on rinkeby use 0x8A753747A1Fa494EC906cE90E9f37563A8AF630e otherwise mock
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        price_feed_address = config["networks"][network.show_active()][
            "eth_usd_price_feed"
        ]
    else:
        mock_aggregator = deploy_mock()
        price_feed_address = mock_aggregator.address

    fund_me = FundMe.deploy(
        price_feed_address,
        {"from": account},
        publish_source=config["networks"][network.show_active()].get(
            "verify"
        ),  # add to verify the contract NOT WORKING on testnet
    )
    print("[Contract deployed at]:", fund_me.address)
    return fund_me


def main():
    deploy_fund_me()
