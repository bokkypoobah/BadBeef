#!/bin/sh
# ----------------------------------------------------------------------------------------------
# Extracting transaction data from the BAT ICO
#
# Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2017. The MIT Licence.
# ----------------------------------------------------------------------------------------------

# geth attach << EOF | grep "RESULT: " | sed "s/RESULT: //"
geth attach << EOF

var contractAddress = "0x1e143b2588705dfea63a17f2032ca123df995ce0";
var contractAbi = [{"constant":false,"inputs":[{"name":"to","type":"address"}],"name":"transfer","outputs":[],"type":"function"},{"constant":false,"inputs":[{"name":"to","type":"address"}],"name":"classicTransfer","outputs":[],"type":"function"},{"inputs":[],"type":"constructor"}];
var contract = web3.eth.contract(contractAbi).at(contractAddress);

var startBlock = 3791822;
var endBlock = 3806244;
var totalEthers = new BigNumber(0);
var totalTokens = new BigNumber(0);

console.log("RESULT: Account\tBlock\tTxIdx\t#\tEthers\tSumEthers\tTokens\tSumTokens\tTimestamp\tDateTime\tTxHash\tGasUsed\tGasPrice\tGasCost");

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
            if (txOk && "0xb4427263" && false) {
                count++;
                var ethers = web3.fromWei(e.value, "ether");
                totalEthers = totalEthers.add(ethers);
                var tokenBalancePrev = token.balanceOf(e.from, parseInt(e.blockNumber) - 1).div(1e18);
                var tokenBalance = token.balanceOf(e.from, e.blockNumber).div(1e18).minus(tokenBalancePrev);
                totalTokens = totalTokens.add(tokenBalance);
                var txr = eth.getTransactionReceipt(e.hash);
                var gasUsed = new BigNumber(txr.gasUsed);
                var gasPrice = e.gasPrice;
                var gasCost = gasUsed.times(gasPrice);
                console.log("RESULT: " + e.from + "\t" + e.blockNumber + "\t" + e.transactionIndex + "\t" + count + "\t" + ethers + "\t" + 
                    totalEthers + "\t" + tokenBalance + "\t" + totalTokens + "\t" + timestamp + "\t" + time.toUTCString() + "\t" + e.hash +
                    "\t" + gasUsed + "\t" + web3.fromWei(gasPrice, "ether") + "\t" + web3.fromWei(gasCost, "ether"));
            }
        }
      });
    }
  }
}

getData();

EOF
