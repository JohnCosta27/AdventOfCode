import { DayFunc } from "..";

export const Day1: DayFunc = (input) => {
  const elfFood: number[][] = input
    .split("\n\n")
    .map((i) => i.split("\n"))
    .map((i) => i.map((j) => parseInt(j)));

  let highest = [0, 0, 0];
  elfFood.forEach((n) => {
    const h = n.reduce((prev, current) => (current += prev));
    const index = highest.findIndex(v => v < h);
    if (index !== -1) highest[index] = h;
    highest.sort();
  });

  return [highest[0], highest.reduce((p, c) => c += p)];
};
