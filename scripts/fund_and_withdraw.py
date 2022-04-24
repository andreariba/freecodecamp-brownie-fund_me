from brownie import FundMe

from scripts.utility import get_account


def fund():
    account = get_account()
    print(account)
    if len(FundMe) > 0:
        fund_me = FundMe[-1]
    else:
        fund_me = FundMe(account)
    entrance_fee = fund_me.getEntranceFee()
    print("The current entrance fee is", entrance_fee)
    # send entrance fee to the contract (16666666)
    fund_me.fund({"from": account, "value": entrance_fee})


def withdraw():
    account = get_account()
    print(account)
    if len(FundMe) > 0:
        fund_me = FundMe[-1]
    else:
        fund_me = FundMe(account)
    # withdraw
    fund_me.withdraw({"from": account})


def main():
    fund()
    withdraw()
