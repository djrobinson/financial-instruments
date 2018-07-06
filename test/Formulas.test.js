const assert = require('assert');
const ganache = require('ganache-cli');
const Web3 = require('web3');
// Creates instance of web3 and plugs in ganache as provider
const provider = ganache.provider();
const web3 = new Web3(provider);
const { interface, bytecode } = require('../compile');

let accounts;
let financialFormulas;

beforeEach(async () => {
  accounts = await web3.eth.getAccounts();

  financialFormulas = await new web3.eth.Contract(JSON.parse(interface))
    .deploy({ data: bytecode })
    .send({ from: accounts[0], gas: '1000000'})

  financialFormulas.setProvider(provider);
});

describe('FinancialFormulas', () => {
  it('deploys a contract', () => {
    assert.ok(financialFormulas.options.address);
  });
  it('Calculates happy path PMT', async () => {
    const message = await financialFormulas.methods.pmt(50, 24, 50000, 0, false).call();
    assert.equal(message, 2216);
  });
  it('Calculates happy path PPMT', async () => {
    const message = await financialFormulas.methods.ppmt(50, 4, 24, 50000, 0, false).call();
    assert.equal(message, 1996);
  });
  it('Calculates happy path IPMT', async () => {
    const message = await financialFormulas.methods.ipmt(50, 4, 24, 50000, 0, false).call();
    assert.equal(message, 220);
  });
  // PAYMENT DOESN'T WORK YET. SET TO ZERO IN THIS TEST
  it('Calculates happy path FV', async () => {
    const message = await financialFormulas.methods.fv(50, 24, 0, 50000, false).call();
    assert.equal(message, 56357);
  });
});
