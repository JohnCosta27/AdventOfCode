import { DayFunc } from "..";

export const Day4: DayFunc = (input) => {
  const pairs: number[][][] = input
    .trim()
    .split("\n")
    .map((l) => l.split(",").map((p) => p.split("-").map((v) => parseInt(v))));

  const [part1, part2] = pairs.reduce(
    ([part1, part2], next) => {
      if (
        (next[0][0] <= next[1][0] && next[0][1] >= next[1][1]) ||
        (next[1][0] <= next[0][0] && next[1][1] >= next[0][1])
      ) {
        part1++;
        part2++;
      } else if (
        (next[0][0] <= next[1][0] && next[1][0] <= next[0][1]) ||
        (next[1][0] <= next[0][0] && next[0][0] <= next[1][1])
      ) {
        part2++;
      }
      return [part1, part2];
    },
    [0, 0]
  );

  return [part1, part2];
};
