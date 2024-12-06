import { DayFunc } from "..";

type MonkeyList = Record<
  number,
  {
    inspected: number;
    items: string[];
    operation: string;
    test: number;
    ifTrue: number;
    ifFalse: number;
  }
>;

const Hcf = (a: number, b: number): number => {
  let larger = a > b ? a : b;
  let smaller = a > b ? b : a;

  let r = -1;

  while (true) {
    if (larger % smaller === 0) break;
    r = larger % smaller;
    larger = smaller;
    smaller = r;
  }

  return r;
}

export const Day11: DayFunc = (input) => {
  const parsed = input
    .trim()
    .split("\n\n")
    .map((v) => v.split("\n").map((i) => i.trim()));
  const list: MonkeyList = parsed.reduce((prev, next) => {
    const num = next[0].split(" ")[1].slice(0, -1);
    const items = next[1]
      .split(" ")
      .slice(2)
      .map((i) => i.replace(",", ""));
    const op = next[2].split("new = old ")[1];
    const test = parseInt(next[3].split(" ").pop());
    const ifTrue = parseInt(next[4].split(" ").pop());
    const ifFalse = parseInt(next[5].split(" ").pop());
    prev[num] = {
      items: items,
      operation: op,
      test: test,
      ifTrue: ifTrue,
      ifFalse: ifFalse,
      inspected: 0,
    };
    return prev;
  }, {});

  const part1List: MonkeyList = JSON.parse(JSON.stringify(list));
  const part2List: MonkeyList = JSON.parse(JSON.stringify(list));

  for (let round = 1; round <= 20; round++) {
    Object.values(part1List).forEach((v) => {
      v.items.forEach(old => {
        v.inspected++;
        let newVal = eval(`${old}${v.operation.replace('old', old.toString())}`);
        newVal = Math.floor(newVal / 3);
        if (newVal % v.test === 0) {
          part1List[v.ifTrue].items.push(newVal);
        } else {
          part1List[v.ifFalse].items.push(newVal);
        }
      });
      v.items = [];
    });
  }

  const part1 = Object.values(part1List).map(v => v.inspected).sort((a, b) => b - a);
  const product = Object.values(part2List).reduce((p, v) => p * v.test, 1);

  for (let round = 0; round < 10000; round++) {

    Object.values(part2List).forEach((v) => {
      v.inspected += v.items.length;
      v.items.forEach(old => {
        let newVal = eval(`${old}${v.operation.replace('old', old.toString())}`);
        if (newVal > product) {
          newVal = newVal % product;
        }
        if (newVal % v.test === 0) {
          part2List[v.ifTrue].items.push(newVal);
        } else {
          part2List[v.ifFalse].items.push(newVal);
        }
      });
      v.items = [];
    });

  }

  const part2 = Object.values(part2List).map(v => v.inspected).sort((a, b) => b - a);
  console.log(part2);

  return [part1[0] * part1[1], part2[0] * part2[1]];
};
