# BadBeef

From [WARNING: Do NOT Use SafeConditionalHFTransfer! Or Use It Correctly](https://www.reddit.com/r/ethereum/comments/6er78h/warning_do_not_use_safeconditionalhftransfer_or/):

> The **SafeConditionalHFTransfer** saved a lot of ethers being moved incorrectly on the wrong chain after The DAO hard fork. So far there has been 20549 txns + 16022 internalTxns passing through the **SafeConditionalHFTransfer** at [0x1e143b2588705dfea63a17f2032ca123df995ce0](https://etherscan.io/address/0x1e143b2588705dfea63a17f2032ca123df995ce0#code). The author contacted me this morning about 67,317.257581981046981598 ETH ~ USD 14,892,596.89 (@ $221.23/ETH) sent incorrectly to the contract.
> 
> When using this contract, you have to call the `classicTransfer(...)` or `transfer(...)` functions to direct your ETH or ETC to the intended chain. If you send ETH (or ETC) DIRECTLY to the contract address, your ETH (or ETC) will not be redirected to the destination address on the destination chain, but will instead be trapped in this contract FOREVER.
> 
> As the recent clients on both the ETH and ETC chains have [EIP155 Replay Protection](https://github.com/ethereum/EIPs/issues/155) built in, you do NOT have to use this `SafeConditionalHFTransfer` any more. Just make sure you are using a recent client, with EIP155!
> 
> Here are the main clients and the versions implementing EIP155:
> 
> * `geth` Go Ethereum - EIP155 since [Let There Be Light (v1.5.0)](https://github.com/ethereum/go-ethereum/releases/tag/v1.5.0) Nov 16 2016. Latest release [Hat Trick (v1.6.5)](https://github.com/ethereum/go-ethereum/releases).
> * Parity - EIP155 since [Civility (v1.4)](https://blog.ethcore.io/announcing-parity-1-4/) Nov 07 2016. Latest release from [https://parity.io/parity.html](https://parity.io/parity.html) or [https://github.com/paritytech/parity/releases](https://github.com/paritytech/parity/releases)
> * MyEtherWallet (remember to use the right URL https://www.myetherwallet.com/) has EIP155 replay protection.
> 
> This warning has also been placed at the top of the answer to [How to conditionally send ethers to another account post-hard-fork to protect yourself from replay attacks](https://ethereum.stackexchange.com/questions/7396/how-to-conditionally-send-ethers-to-another-account-post-hard-fork-to-protect-yo).

See also [If your exchange is related to 0x027BEEFcBaD782faF69FAD12DeE97Ed894c68549, withdraw immediately, they screwed up a few days ago and lost 60,000 ether](https://www.reddit.com/r/ethereum/comments/6eruqb/if_your_exchange_is_related_to/).

And here is a statement from QuadrigaCX on the issue - [Statement on QuadrigaCX Ether contract error](https://www.reddit.com/r/ethereum/comments/6ettq5/statement_on_quadrigacx_ether_contract_error/).

<br />

<hr />

## Error Transaction Involved

Following are extracts of the transactions that have sent ethers to the **SafeConditionalHFTransfer** contract without specifying either the `classicTransfer(...)` or `transfer(...)` functions.

These transaction are identified by the `input` field starting with `0x00000000` instead of the `web3.sha3("transfer(address)").substring(0, 10)` which is `0x1a695230`.

The script can be found at [scripts/getBadBeefData.sh](scripts/getBadBeefData.sh).

The data at from transactions from block #3752970 can be found in [data/BadBeefData.tsv](data/BadBeefData.tsv) with a spreadsheet representation at [data/BadBeefData.xls](data/BadBeefData.xls).

A total of 67316.2838 ETH was intended to be sent to 0x027beefcbad782faf69fad12dee97ed894c68549 but ended up trapped in the `SafeConditionalHFTransfer` contract. 

<br />

<hr />

## SafeConditionalHFTransfer Source Code

To prevent this error, the following code would have to be added to **SafeConditionalHFTransfer** below:

```javascript
    function () {
        throw;
    }
```

From [0x1e143b2588705dfea63a17f2032ca123df995ce0](https://etherscan.io/address/0x1e143b2588705dfea63a17f2032ca123df995ce0#code):

```javascript
contract ClassicCheck {
       function isClassic() constant returns (bool isClassic);
}

contract SafeConditionalHFTransfer {

    bool classic;

    function SafeConditionalHFTransfer() {
        classic = ClassicCheck(0x882fb4240f9a11e197923d0507de9a983ed69239).isClassic();
    }

    function classicTransfer(address to) {
        if (!classic) 
            msg.sender.send(msg.value);
        else
            to.send(msg.value);
    }

    function transfer(address to) {
        if (classic)
            msg.sender.send(msg.value);
        else
            to.send(msg.value);
    }

}
```

(c) BokkyPooBah / Bok Consulting Pty Ltd - June 02 2017