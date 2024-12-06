import { DayFunc } from "..";

export const Day5: DayFunc = (input) => {
  let [inStacks, instructions] = input
    .split("\n\n")

  const stacks = inStacks.split('\n')
  stacks.pop();

  const numOfStacks = (stacks[0].length + 1) / 4;
  let realStacks = [...Array(numOfStacks)].map(() => []);

  for (let i = 0; i < stacks.length; i++) {
    for (let j = 1; j < stacks[i].length; j += 4) {
      const c = stacks[i].charAt(j);
      const stackNum = (j - 1) / 4;
      if (c !== " ") {
        realStacks[stackNum].push(c);
      }
    }
  }
  realStacks.map(s => s.reverse());
  const realStacks2 = [...realStacks].map(i => [...i]);

  const rules = instructions.split('\n').map((i) => {
    const is = i.split(" ");
    return [parseInt(is[1]), parseInt(is[3]) - 1, parseInt(is[5]) - 1];
  });
  rules.pop();

  rules.forEach(r => {
    for (let i = 0; i < r[0]; i++) {
      const popped = realStacks[r[1]].pop();
      realStacks[r[2]].push(popped);
    }

    const crates = realStacks2[r[1]].splice(-r[0]);
    realStacks2[r[2]].push(...crates);
  });

  const part1 = realStacks.reduce((prev, next) => prev + next[next.length - 1], "");
  const part2 = realStacks2.reduce((prev, next) => prev + next[next.length - 1], "");

  return [part1, part2];
};
