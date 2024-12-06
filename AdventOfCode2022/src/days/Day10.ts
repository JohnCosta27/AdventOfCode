import { DayFunc } from "..";

export const Day10: DayFunc = (input) => {
  const parsed = input.trim().split('\n').map(v => {
    const s = v.split(' ');
    if (s.length === 1) return [s[0]];
    return [s[0], parseInt(s[1])];
  });

  let x = 1;
  let cycles: number[] = [x];

  parsed.forEach(i => {
    if (i[0] === "noop") {
      cycles.push(x);
    } else {
      cycles.push(x);
      cycles.push(x);
      x += i[1] as number;
    }
  });

  const part1 = cycles[20] * 20 + cycles[60] * 60 + cycles[100] * 100 + cycles[140] * 140 + cycles[180] * 180 + cycles[220] * 220;

  let outStr = "";
  for (let i = 1; i < cycles.length; i++) {

    if ((i - 1) % 40 === 0) {
      outStr += '\n';
    }

    if (cycles[i] === (i - 1) % 40 || cycles[i] === (i - 2) % 40 || cycles[i] === i % 40) {
      outStr += '#';
    } else {
      outStr += '.';
    }

  }

  console.log(outStr);
  return [part1, 0];
}
