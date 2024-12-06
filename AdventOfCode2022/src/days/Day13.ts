import { DayFunc } from "..";

const Compare = (a: any, b: any): "left" | "right" | null => {
  if (typeof a === "number" && typeof b === "number") {
    if (a < b) {
      return "right";
    } else if (a > b) {
      return "left";
    } else {
      return null;
    }
  } else if (typeof a === "object" && typeof b === "object") {
    if (a.length === 0 && b.length > 0) return "right";
    if (b.length === 0 && a.length > 0) return "left";
    if (a.length === 0 && b.length === 0) return null; 
    const ans = Compare(a[0], b[0]);
    if (ans !== null) return ans;

    a.shift();
    b.shift();
    return Compare(a, b);
  } else if (typeof a === "object") {
    return Compare(a, [b]);
  } else if (typeof b === "object") {
    return Compare([a], b);
  }
};

export const Day13: DayFunc = (input) => {
  const parsed = input
    .trim()
    .split("\n\n")
    .map((v) => v.split("\n").map((w) => JSON.parse(w)));

  const part2Parsed = input.trim().replaceAll('\n\n', '\n').split('\n').map(v => JSON.parse(v));
  part2Parsed.push([[2]]);
  part2Parsed.push([[6]]);

  let part1 = 0;
  parsed.forEach(([a, b], i) => {
    const side = Compare(a, b);
    if (side === "right") {
      part1 += i + 1;
    }
  });

  part2Parsed.sort((a, b) => {
    if (Compare(JSON.parse(JSON.stringify(a)), JSON.parse(JSON.stringify(b))) === "left") return 1
    return -1;
  });

  const two = part2Parsed.findIndex(i => JSON.stringify(i) === JSON.stringify([[2]])) + 1;
  const six = part2Parsed.findIndex(i => JSON.stringify(i) === JSON.stringify([[6]])) + 1;

  return [part1, two * six];
};
