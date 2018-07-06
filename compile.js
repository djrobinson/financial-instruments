const path = require('path');
const solc = require('solc');
const fs = require('fs-extra');

// Finds the build folder
const buildPath = path.resolve(__dirname, 'build');
// Deletes the old build
fs.removeSync(buildPath);

// Create formulas path
const formulasPath = path.resolve(__dirname, 'contracts', 'Formulas.sol');
// Find file at formulas path
const source = fs.readFileSync(formulasPath, 'utf8');
console.log("Source? ", source);
const output = solc.compile(source, 1).contracts;
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

module.exports = output[':FinancialFormulas'];