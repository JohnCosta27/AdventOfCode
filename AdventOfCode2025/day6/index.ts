const file = Bun.file("./input.txt");
const content = await file.text().then((c) => c.trim());

const filterNonEmpty = (i: string) => i.length > 0

type Problem = {
    operation: string
    numbers: number[]
}

const problems: Problem[] = [];

const splitContent = content.split("\n")
const operationsRow = splitContent.pop()!.split(" ").filter(filterNonEmpty)

for (const line of splitContent) {
    const numbers = line.split(" ").filter(filterNonEmpty);
    if (problems.length === 0) {
        for (let i = 0; i < numbers.length; i++) {
            problems.push({
                operation: '',
                numbers: [],
            })
        }
    }

    for (let i = 0; i < numbers.length; i++) {
        problems[i]!.numbers.push(parseInt(numbers[i]!))
    }
}

for (const [index, problem] of problems.entries()) {
    problem.operation = operationsRow[index]!
}

const getReducer = (op: string): (nums: number[]) => number => {
    switch (op) {
        case '*':
            return (nums) => nums.reduce((n, acc) => acc * n, 1)
        case '+':
            return (nums) => nums.reduce((n, acc) => acc + n, 0)
        default:
            throw new Error("operation not supported")
    }
}

const solve = (problems: Problem[]): number => {
    let part1 = 0;

    for (const problem of problems) {
        const reducer = getReducer(problem.operation)
        part1 += reducer(problem.numbers)
    }

    return part1
}

const transposeProblems = (str: string): Problem[] => {
    const charArr = str.split("\n").map(c => c.split(""))

    const newCharArr: string[][] = [];

    for (let i = 0; i < charArr.length; i++) {
        for (let j = 0; j < charArr[0]!.length; j++) {
            if (!newCharArr[j]) {
                newCharArr[j] = []
            }
            newCharArr[j]![i]! = charArr[i]![j]! ?? ' '
        }
    }

    const problems: Problem[] = [];
    let workingProblem: Problem = {
        numbers: [],
        operation: ""
    }
    let index = 0;

    for (const line of newCharArr) {
        if (line.every(c => c === " ")) {
            problems.push(workingProblem)
            workingProblem = {
                numbers: [],
                operation: ''
            }
            index = 0
            continue
        }

        if (index === 0) {
            const op = line.pop()
            if (op !== " ") {
                workingProblem.operation = op!
            }
        }

        const numbers = line.filter(c => c !== " ")
        if (numbers.length === 0) {
            continue
        }

        const number = parseInt(numbers.join(""))
        workingProblem.numbers.push(number)
    }

    problems.push(workingProblem)

    return problems
}

const part1 = solve(problems)
console.log("Part 1: ", part1)

const part2Problems = transposeProblems(content)
const part2 = solve(part2Problems)
console.log("Part 2: ", part2)
