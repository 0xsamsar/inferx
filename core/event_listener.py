import json
from web3 import Web3
import asyncio


web3 = Web3(Web3.HTTPProvider('http://127.0.0.1:8545'))

inferencer_node = ''
inferencer_node_abi = json.loads('')
contract = web3.eth.contract(address=inferencer_node, abi=inferencer_node_abi)


def handle_event(event):
    print(Web3.toJSON(event))
    #TODO decode -> interpret -> process


async def log_loop(event_filter, poll_interval):
    while True:
        for PairCreated in event_filter.get_new_entries():
            handle_event(PairCreated)
        await asyncio.sleep(poll_interval)



def main():
    event_filter = contract.events.InferencerRequested.createFilter(fromBlock='latest')

    loop = asyncio.get_event_loop()
    try:
        loop.run_until_complete(
            asyncio.gather(
                log_loop(event_filter, 1)))

    finally:
        loop.close()


if __name__ == "__main__":
    main()