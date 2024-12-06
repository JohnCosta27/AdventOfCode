const fs = require('fs');
const obj = JSON.parse(fs.readFileSync('day12.json', 'utf8'));

console.log("Part 1: " + solver(obj));
console.log("Part 2: ", + solverPart2(obj));

function solver(json) {

    let counter = 0;

    for (let value in json) {
        if (typeof json[value] == 'number') {
            counter += json[value]
        } else if (typeof json[value] == 'boolean') {

        } else if (typeof json[value] == 'string') {
            
        } else if (typeof json[value] == 'object') {
            counter += solver(json[value]);
        }
    }

    return counter;

}

function solverPart2(json) {
    let counter = 0;
    let redFound = false;
    let toSolver = [];

    for (let value in json) {
        if (typeof json[value] == 'number') {
            counter += json[value]
        } else if (typeof json[value] == 'boolean') {

        } else if (typeof json[value] == 'string') {
            if (json[value] == 'red' && !Array.isArray(json)) {
                redFound = true;
                break;
            }
        } else if (typeof json[value] == 'object') {
            toSolver.push(json[value]);
        }
    }

    if (redFound) {
        return 0;
    } else {
        for (let e of toSolver) {
            counter += solverPart2(e);
        }
        return counter;
    }
}