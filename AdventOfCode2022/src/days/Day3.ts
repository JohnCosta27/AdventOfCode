import { DayFunc } from "..";

const getCode = (x: Set<string>): number => {
  const code = x.values().next().value.charCodeAt(0);
  return code + (code <= 90 ? -38 : -96);
};

export const Day3: DayFunc = (input) => {
  const bags: string[] = input
    .trim()
    .split("\n")

  const part1Bags = bags.map((i) => [i.slice(0, i.length / 2), i.slice(i.length / 2)]);
  const part2Bags = []
  for (let i = 0; i < bags.length; i += 3) {
    part2Bags.push(bags.slice(i, i + 3));
  }

  const part1 = part1Bags.reduce((prev, [c1, c2]) => {
    const set1 = new Set(c1);
    const set2 = new Set(c2);
    const n = new Set([...set1].filter((x) => set2.has(x)));
    return prev + getCode(n);
  }, 0);

  const part2 = part2Bags.reduce((prev, [c1, c2, c3]) => {
    const set1 = new Set(c1);
    const set2 = new Set(c2);
    const set3 = new Set(c3);
    const n = new Set([...set1].filter((x) => set2.has(x)).filter(x => set3.has(x)));
    return prev + getCode(n as Set<string>);
  }, 0)

  return [part1, part2];
};
