import { DayFunc } from "..";

const FindRepeated = (input: string, gap: number): number => {
  for (let i = 0; i < input.length - gap; i++) {
    const sub = input.substring(i, i + gap);
    let changed = false;
    for (const c of sub) {
      if (sub.split(c).length > 2) {
        i += sub.indexOf(c);
        changed = true;
        break;
      }
    }
    if (!changed) return i + gap;
  }
  return -1;
}

export const Day6: DayFunc = (input) => {
  return [FindRepeated(input, 4), FindRepeated(input, 14)];
}
