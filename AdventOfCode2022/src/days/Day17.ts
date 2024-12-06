import { DayFunc } from "..";

const blocks = [
  [["@", "@", "@", "@"]],
  [
    [".", "@", "."],
    ["@", "@", "@"],
    [".", "@", "."],
  ],
  [
    [".", ".", "@"],
    [".", ".", "@"],
    ["@", "@", "@"],
  ],
  [["@"], ["@"], ["@"], ["@"]],
  [
    ["@", "@"],
    ["@", "@"],
  ],
];

function PrintGrid(grid: string[][]) {
  for (let i = grid.length - 1; i >= 0; i--) {
    for (let j = 0; j < grid[0].length; j++) {
      process.stdout.write(grid[i][j]);
    }
    process.stdout.write("\n");
  }
  process.stdout.write("++++++++++++++++++++++++++++\n");
}

function MoveDown(
  grid: string[][],
  block: string[][],
  [x, y]: [number, number]
): boolean {
  // Moving through the floor.
  if (y - block.length + 1 === 0) return false;
  for (let i = block.length - 1; i >= 0; i--) {
    for (let j = 0; j < block[0].length; j++) {
      if (block[i][j] === "@" && grid[y - i - 1][j + x] === "#") {
        return false;
      }
    }
  }

  // No collision. Clear block.
  for (let i = block.length - 1; i >= 0; i--) {
    for (let j = 0; j < block[0].length; j++) {
      if (block[i][j] === "@") {
        grid[y - i][j + x] = ".";
      }
    }
  }
  y--;
  for (let i = block.length - 1; i >= 0; i--) {
    for (let j = 0; j < block[0].length; j++) {
      if (block[i][j] === "@") {
        grid[y - i][j + x] = "@";
      }
    }
  }
  return true;
}

function MoveSides(
  grid: string[][],
  block: string[][],
  [x, y]: [number, number],
  unit: -1 | 1
): boolean {
  // Goes off the sides
  if (x + unit < 0 || x + block[0].length + unit > grid[0].length) return false;
  for (let i = block.length - 1; i >= 0; i--) {
    for (let j = 0; j < block[0].length; j++) {
      if (block[i][j] === "@" && grid[y - i][j + x + unit] === "#") {
        return false;
      }
    }
  }

  // No collision. Clear block.
  for (let i = block.length - 1; i >= 0; i--) {
    for (let j = 0; j < block[0].length; j++) {
      if (block[i][j] === "@") {
        grid[y - i][j + x] = ".";
      }
    }
  }
  x += unit;
  for (let i = block.length - 1; i >= 0; i--) {
    for (let j = 0; j < block[0].length; j++) {
      if (block[i][j] === "@") {
        grid[y - i][j + x] = "@";
      }
    }
  }
  return true;
}

function SettleBlock(
  grid: string[][],
  block: string[][],
  [x, y]: [number, number]
) {
  for (let i = block.length - 1; i >= 0; i--) {
    for (let j = 0; j < block[0].length; j++) {
      if (block[i][j] === "@") {
        grid[y - i][j + x] = "#";
      }
    }
  }
}

function* BlockGen(start = 0, end = Infinity, step = 1) {
  for (let i = start; i < end; i += step) {
    yield { block: blocks[i % blocks.length]!, index: i % blocks.length };
  }
}

function CalcHeight(grid: string[][]) {
  let e = 0;
  for (let i = grid.length - 1; i >= 0; i--) {
    if (grid[i].some((j) => j === "#")) {
      break;
    }
    e++;
  }
  return grid.length - e;
}

export const Day17: DayFunc = (input) => {
  const parsed = input.trim().split("");
  const gen = BlockGen();

  const grid: string[][] = [];
  let jet = 0;
  let part1: number;
  let addedOnHeight = 0;

  const depthMap: Record<string, {height: number; index: number}> = {};

  for (let i = 0; i < 1e12; i++) {
    if (i === 2022) {
      part1 = CalcHeight(grid);
    }

    const g = gen.next().value;
    if (!g) return;
    const block = g.block;

    // Not right, not necessarily the top row.
    let emptyRows = 0;
    let rock = -1;
    for (let c = grid.length - 1; c >= 0; c--) {
      if (grid[c].some((i) => i === "#")) {
        rock = c;
        break;
      }
      emptyRows++;
    }
    if (emptyRows < 3 + block.length) {
      for (let c = 0; c <= 2 + block.length - emptyRows; c++) {
        grid.push([".", ".", ".", ".", ".", ".", "."]);
      }
    }
    const topLeft: [number, number] = [2, rock + 3 + block.length];

    for (let j = block.length - 1; j >= 0; j--) {
      const newRow = [".", ".", ...block[j]];
      for (let k = 0; k < 5 - block[j].length; k++) {
        newRow.push(".");
      }
      grid[rock === -1 ? 3 - j : block.length - j + rock + 3] = newRow;
    }

    let movedDown = true;
    do {
      if (parsed[jet % parsed.length] === "<") {
        const moved = MoveSides(grid, block, topLeft, -1);
        if (moved) topLeft[0]--;
      } else {
        const moved = MoveSides(grid, block, topLeft, 1);
        if (moved) topLeft[0]++;
      }
      jet++;
      movedDown = MoveDown(grid, block, topLeft);
      if (movedDown) {
        topLeft[1]--;
      }
    } while (movedDown);
    SettleBlock(grid, block, topLeft);

    const depth = [0, 0, 0, 0, 0, 0, 0];
    for (let x = 0; x < 7; x++) {
      for (let y = grid.length - 1; y >= 0; y--) {
        if (grid[y][x] === '#') {
          depth[x] = grid.length - y;
          break;
        }
      }
    }
    const key = `${g.index},${jet % parsed.length},${JSON.stringify(depth)}`;
    if (key in depthMap) {
      const height = CalcHeight(grid);
      const mapEntry = depthMap[key];
      const diff = height - mapEntry.height;
      const cycleNum = Math.floor((1e12 - i) / (i - mapEntry.index));
      i += cycleNum * (i - mapEntry.index);
      addedOnHeight += diff * cycleNum;
    } else {
      depthMap[key] = { height: CalcHeight(grid), index: i };
    }

  }

  return [part1, CalcHeight(grid) + addedOnHeight];
};
