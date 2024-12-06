import { file } from "bun";
import {
  Day1,
  Day2,
  Day3,
  Day4,
  Day5,
  Day6,
  Day7,
  Day8,
  Day9,
  Day10,
  Day11,
  Day12,
  Day13,
  Day14,
  Day17,
  Day15,
  Day18,
} from "./days";

export type DayFunc = (input: string) => [any, any];
export const UP = "\033[F";

const RunDay = async (
  dayFunc: (input: string) => [number, number],
  dayPath: string
) => {
  console.time("Time Taken");
  const dayInput = await file(`./inputs/${dayPath}.txt`).text();
  const [part1, part2] = dayFunc(dayInput);

  console.log(
    `------------------Day ${dayPath.charAt(
      dayPath.length - 1
    )}--------------------`
  );
  console.log("Part 1:", part1);
  console.log("Part 2:", part2);
  console.timeEnd("Time Taken");
  console.log("------------------------------------------");
};

console.log("Advent Of Code - 2022");
console.time("total");

// await RunDay(Day1, 'day1');
// await RunDay(Day2, 'day2');
// await RunDay(Day3, 'day3');
// await RunDay(Day4, 'day4');
// await RunDay(Day5, 'day5');
// await RunDay(Day6, 'day6');
// await RunDay(Day7, 'day7');
// await RunDay(Day8, 'day8');
// await RunDay(Day9, 'day9');
// await RunDay(Day10, 'day10');
// await RunDay(Day11, 'day11');
// await RunDay(Day12, 'day12');
// await RunDay(Day13, 'day13');
// await RunDay(Day14, "day14");
// await RunDay(Day17, "day17");
await RunDay(Day18, 'day18');
console.timeEnd("total");
