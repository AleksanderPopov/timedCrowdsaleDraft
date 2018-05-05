module.exports = {
    toWei(etherValue) {
        console.log('to wei called - ' + etherValue);
        return web3.toWei(etherValue, 'ether')
    },
    toEther(weiValue) {
        console.log('to ether called - ' + weiValue);
        return web3.fromWei(weiValue, 'ether')
    },
    forwardTimeForSeconds(seconds) {
        web3.currentProvider.sendAsync({
            jsonrpc: '2.0',
            method: 'evm_increaseTime',
            params: [seconds],
            id: new Date().getSeconds()
        }, (err, resp) => {
            if (err) throw err;
            web3.currentProvider.send({jsonrpc: '2.0', method: 'evm_mine', params: [], id: new Date().getSeconds()})
        });
    }
};