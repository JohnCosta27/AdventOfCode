import { DayFunc } from "..";

const GetSmaller = (arr: number[], target: number): number => {
  let i = 0;
  for (; i < arr.length && arr[i] < target; i++) {}
  return i;
};

const Part2 = (arr: number[], target: number): number => {
  const i = arr.findIndex(i => i >= target);
  if (i === -1) {
    return arr.length;
  }
  return i + 1;
}

export const Day8: DayFunc = (input) => {
  const parsed: number[][] = input
    .trim()
    .split("\n")
    .map((v) => v.split("").map((i) => parseInt(i)));
  const transposed = parsed[0].map((_, colIndex) =>
    parsed.map((row) => row[colIndex])
  );

  let part1 = parsed.length * 2 + parsed[0].length * 2 - 4;
  let part2 = 0;

  for (let i = 1; i < parsed.length - 1; i++) {
    for (let j = 1; j < parsed[0].length - 1; j++) {
      const c = parsed[i][j];
      const row = parsed[i];
      const col = transposed[j];

      const left = row.slice(0, j).reverse();
      const right = row.slice(j + 1);
      const top = col.slice(0, i).reverse();
      const bottom = col.slice(i + 1);

      if (
        GetSmaller(left, c) === left.length ||
        GetSmaller(right, c) === right.length ||
        GetSmaller(top, c) === top.length ||
        GetSmaller(bottom, c) === bottom.length
      ) {
        part1++;
      }

      const view = Part2(left, c) * Part2(right, c) * Part2(top, c) * Part2(bottom, c);
      if (view > part2) {
        part2 = view;
      }
    }
  }

  return [part1, part2];
};
