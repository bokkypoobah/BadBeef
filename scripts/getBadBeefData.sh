#!/bin/sh
# ----------------------------------------------------------------------------------------------
# Extracting transaction data from the BAT ICO
#
# Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2017. The MIT Licence.
# ----------------------------------------------------------------------------------------------

geth attach << EOF | grep "RESULT: " | sed "s/RESULT: //"
// geth attach << EOF

var contractAddress = "0x1e143b2588705dfea63a17f2032ca123df995ce0";
var contractAbi = [{"constant":false,"inputs":[{"name":"to","type":"address"}],"name":"transfer","outputs":[],"type":"function"},{"constant":false,"inputs":[{"name":"to","type":"address"}],"name":"classicTransfer","outputs":[],"type":"function"},{"inputs":[],"type":"constructor"}];
var contract = web3.eth.contract(contractAbi).at(contractAddress);

var startBlock = 3791822;
var endBlock = eth.blockNumber;
// startBlock = parseInt(endBlock) - 100;
var totalBadBeefEthers = new BigNumber(0);

console.log("RESULT: Account\tTo\tBlock\tTxIdx\t#\tBadBeefEthers\tSumBadBeefEthers\tTimestamp\tDateTime\tTxHash");

function getData() {
  var count = 0;
  for (var i = startBlock; i <= endBlock; i++) {
    var block = eth.getBlock(i, true);
    var timestamp = block.timestamp;
    var time = new Date(timestamp * 1000);
    if (block != null && block.transactions != null) {
      block.transactions.forEach( function(e) {
        if (e.to == contractAddress) {
            console.log("DEBUG: " + JSON.stringify(e));
            var status = debug.traceTransaction(e.hash);
            var txOk = true;
            if (status.structLogs.length > 0) {
                if (status.structLogs[status.structLogs.length-1].error) {
                    txOk = false;
                }
            }
            if (txOk) {
                count++;
                var ethers = web3.fromWei(e.value, "ether");
                if (e.input.substring(0, 10) == "0x00000000") {
                    totalBadBeefEthers = totalBadBeefEthers.add(ethers);
                    var to = e.input.substring(27, 66);
                    console.log("RESULT: " + e.from + "\t" + to + "\t" + e.blockNumber + "\t" + e.transactionIndex + "\t" + count + "\t" + ethers + "\t" + 
                        totalBadBeefEthers + "\t" + "\t" + timestamp + "\t" + time.toUTCString() + "\t" + e.hash);
                }
            }
        }
      });
    }
  }
}

getData();

EOF
