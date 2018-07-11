const path = require('path');
const solc = require('solc');
const fs = require('fs-extra');

// Finds the build folder
const buildPath = path.resolve(__dirname, 'build');
// Deletes the old build
fs.removeSync(buildPath);

// Create formulas path
const loanFactoryPath = path.resolve(__dirname, 'contracts', 'LoanFactory.sol');
const termFixedPath = path.resolve(__dirname, 'contracts', 'TermFixedRate.sol');
const formulasPath = path.resolve(__dirname, 'contracts', 'Formulas.sol');
// Find file at formulas path
console.log('Sanity Check!');

// Load all source files for input
const contractSource = {
  'LoanFactory.sol':  fs.readFileSync(loanFactoryPath, 'utf8'),
  'TermFixedRate.sol': fs.readFileSync(termFixedPath, 'utf8')
}

console.log("Source? ", contractSource);
const output = solc.compile({sources: contractSource}, 1).contracts;
console.log("Output? ", output);

// Creates build folder
fs.ensureDirSync(buildPath);

// Goes through each contract in output, create json of solc compiled contract
for (let contract in output) {
  fs.outputJsonSync(
    path.resolve(buildPath, contract.replace(':', '') + '.json'),
    output[contract]
  );
}

module.exports = output[':FinancialInstruments'];