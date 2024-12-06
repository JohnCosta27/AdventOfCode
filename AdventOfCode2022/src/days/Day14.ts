import { DayFunc, UP } from "..";

const writer = Bun.stdout.writer();

const PrintGrid = async (g: string[][]) => {
  for (let i = 0; i < g.length; i++) {
    for (let j = 0; j < g[0].length; j++) {
      process.stdout.write(g[i][j]);
    }
    process.stdout.write('\n');
  }
  for (let i = 0; i < g.length; i++) {
    process.stdout.write(UP)
  }
};

const EraseSand = ([x, y]: [number, number]) => {
  process.stdout.write(`\033[${y}B`);
  process.stdout.write(`\033[${x}C`);
  process.stdout.write('.');
  process.stdout.write(`\033[${y}A`);
  process.stdout.write(`\033[${x + 1}D`);
}

const PrintSand = ([x, y]: [number, number]) => {
  process.stdout.write(`\033[${y}B`);
  process.stdout.write(`\033[${x}C`);
  process.stdout.write('+');
  process.stdout.write(`\033[${y}A`);
  process.stdout.write(`\033[${x + 1}D`);
}

let minX = 0;
let maxX = 0;
let ySize = 0;

// Returns true if the sand has settled.
const OneTick = (
  [y, x]: [number, number],
  grid: string[][]
): [boolean, boolean, [number, number]] => {
  const next = grid[y + 1][x];

  if (grid[y + 1][x] === undefined) {
    return [false, true, [0, 0]];
  }

  if (next === ".") {
    grid[y][x] = ".";
    grid[y + 1][x] = "+";
    return [false, false, [y + 1, x]];
  } else {

    if (grid[y + 1][x - 1] === ".") {
      grid[y][x] = ".";
      grid[y + 1][x - 1] = "+";
      return [false, false, [y + 1, x - 1]];
    } else if (grid[y + 1][x - 1] === undefined) {
      return [false, true, [0, 0]];
    } else if (grid[y + 1][x + 1] === ".") {
      grid[y][x] = ".";
      grid[y + 1][x + 1] = "+";
      return [false, false, [y + 1, x + 1]];
    } else if (grid[y + 1][x + 1] === undefined) {
      return [false, true, [0, 0]];
    } else {
      //Settled
      grid[y][x] = "o";
      return [true, false, [y, x]];
    }
  }
};

export const Day14: DayFunc = (input) => {
  const parsed = input
    .trim()
    .split("\n")
    .map((i) =>
      i.split(" -> ").map((v) => v.split(",").map((w) => parseInt(w)))
    );

  const xs = parsed.flatMap((v) => v).map((v) => v[0]);
  const ys = parsed.flatMap((v) => v).map((v) => v[1]);
  minX = Math.min(...xs);
  maxX = Math.max(...xs);
  const xSize = maxX - minX;
  ySize = Math.max(...ys);

  let sand: [number, number] = [0, 500 - minX];

  const grid = Array.from({ length: ySize + 1 }, (_) =>
    new Array(xSize + 1).fill(".")
  );
  parsed.forEach((rocks) => {
    for (let i = 0; i < rocks.length - 1; i++) {
      const [x1, y1] = rocks[i];
      const [x2, y2] = rocks[i + 1];
      if (x1 === x2) {
        const startY = Math.min(y1, y2);
        const endY = Math.max(y1, y2);
        for (let j = startY; j <= endY; j++) {
          grid[j][x1 - minX] = "#";
        }
      } else {
        const startX = Math.min(x1, x2) - minX;
        const endX = Math.max(x1, x2) - minX;
        for (let j = startX; j <= endX; j++) {
          grid[y1][j] = "#";
        }
      }
    }
  });
  PrintGrid(grid);
  grid[sand[0]][sand[1]] = "+";

  const increaseSize = 200;
  const part2Grid: string[][] = JSON.parse(JSON.stringify(grid));
  for (let i = 0; i < part2Grid.length; i++) {
    part2Grid[i] = [...Array(increaseSize).fill("."), ...part2Grid[i], ...Array(increaseSize).fill(".")];
  }

  part2Grid.push(Array(xSize + increaseSize * 2 + 1).fill("."));
  part2Grid.push(Array(xSize + increaseSize * 2 + 1).fill("#"));

  while (true) {
    Bun.sleepSync(0.01);
    const [settled, gameOver, newSand] = OneTick(sand, grid);
    EraseSand([sand[1], sand[0]]);

    if (gameOver) {
      grid[sand[0]][sand[1]] = ".";
      break;
    }

    if (!settled) {
      sand = newSand;
    } else {
      sand = [0, 500 - minX];
      grid[sand[0]][sand[1]] = "+";
    }
    PrintSand([sand[1], sand[0]]);
  }
    for (let i = 0; i < grid.length; i++) {
     process.stdout.write('\n');
    }

  const part1 = grid.reduce((p, n) => p + n.filter((i) => i === "o").length, 0);

  minX = minX - increaseSize;
  ySize = ySize + 2;
  sand = [0, 500 - minX];
  while (true) {
    // Bun.sleepSync(0.001);
    // PrintGrid(part2Grid);
    const [settled, gameOver, newSand] = OneTick(sand, part2Grid);
    if (gameOver) {
      part2Grid[sand[0]][sand[1]] = ".";
      break;
    }

    if (!settled) {
      sand = newSand;
    } else {
      if (newSand[0] === 0 && newSand[1] === 500 - minX) {
        part2Grid[0][500 - minX] = 'o';
        break;
      }
      sand = [0, 500 - minX];
      part2Grid[sand[0]][sand[1]] = "+";
    }
  }
    for (let i = 0; i < grid.length; i++) {
      writer.write('\n');
    }
  const part2 = part2Grid.reduce((p, n) => p + n.filter((i) => i === "o").length, 0);

  return [part1, part2];
};
