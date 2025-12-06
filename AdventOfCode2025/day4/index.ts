const file = Bun.file("./input.txt");
const content = await file.text();

const EMPTY = ".";
const PAPER = "@";

const splitContent = [...content.trim().split("\n")]
const lineSize = splitContent[0]!.length

const grid = [
    '.'.repeat(lineSize),
    ...splitContent,
    '.'.repeat(lineSize),
].map(l => `.${l}.`.split(""))

const solve = (grid: string[][]): [number, string[][]] => {
    let paperRemoved = 0;
    const newGrid = structuredClone(grid)

    for (let y = 1; y < grid.length - 1; y++) {
        for (let x = 1; x < grid[0]!.length - 1; x++) {
            let adjacentPapers = 0;

            const currentSquare = grid?.[y]?.[x]
            if (!currentSquare) {
                throw new Error("current square must be defined")
            }

            if (currentSquare === EMPTY) {
                continue
            }

            for (let yOffset = -1; yOffset <= 1; yOffset++) {
                for (let xOffset = -1; xOffset <= 1; xOffset++) {
                    if (yOffset === 0 && xOffset === 0) {
                        continue
                    }

                    const square = grid![y + yOffset]![x + xOffset]!
                    if (square === PAPER) {
                        adjacentPapers++
                    }
                }
            }

            if (adjacentPapers < 4) {
                newGrid![y]![x] = EMPTY
                paperRemoved++
            }
        }
    }

    return [paperRemoved, newGrid]
}

const removePaper = (grid: string[][]): number => {
    let totalPaperRemoved = 0;
    let currentGrid = grid

    while (true) {
        const [paperRemoved, newGrid] = solve(currentGrid)
        currentGrid = newGrid

        if (paperRemoved === 0) {
            break
        }

        totalPaperRemoved += paperRemoved
    }

    return totalPaperRemoved
}

const [part1] = solve(grid)
const part2 = removePaper(grid)

console.log("Part 1: ", part1)
console.log("Part 2: ", part2)
