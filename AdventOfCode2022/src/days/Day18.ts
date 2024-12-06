import { DayFunc } from "..";

function CalcDist(
  [x1, y1, z1]: [number, number, number],
  [x2, y2, z2]: [number, number, number]
): number {
  return Math.sqrt((x1 - x2) ** 2 + (y1 - y2) ** 2 + (z1 - z2) ** 2);
}

export const Day18: DayFunc = (input) => {
  const parsed = input
    .trim()
    .split("\n")
    .map((i) => i.split(",").map((j) => parseInt(j)));

  let part1 = parsed.length * 6;
  for (let i = 0; i < parsed.length; i++) {
    const a = parsed[i];
    for (let j = 0; j < parsed.length; j++) {
      if (i === j) continue;
      const b = parsed[j];
      // @ts-ignore
      const dist = CalcDist(a, b);
      if (dist === 1) {
        part1--;
      }
    }
  }

  return [part1, 0];
};
