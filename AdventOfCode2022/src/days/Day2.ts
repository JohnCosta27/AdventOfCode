import { DayFunc } from "..";

// A = Rock, B = Paper, C = Scissors
// X = Rock, Y = Paper, Z = Scissors
// 1 = Rock, 2 = Paper, 3 = Scissors
// 0 = Lose, 3 = Draw, 6 = Win
type Options = 'r' | 'p' | 's';

const mapping: {[key: string]: Options} = {
  A: 'r',
  B: 'p',
  C: 's',
  X: 'r',
  Y: 'p',
  Z: 's',
}

const scores: Record<
  Options,
  {
    score: number;
    beats: Options;
    loses: Options;
  }
> = {
  'r': {
    score: 1,
    beats: "s",
    loses: "p",
  },
  'p': {
    score: 2,
    beats: "r",
    loses: "s",
  },
  's': {
    score: 3,
    beats: "p",
    loses: "r",
  },
};

export const Day2: DayFunc = (input) => {
  const plays: string[][] = input
    .trim()
    .split("\n")
    .map((line) => line.split(" "));

  let part1 = 0;
  let part2 = 0;

  plays.forEach(([opp, you]) => {
    part1 += scores[mapping[you]].score;
    if (mapping[you] === mapping[opp]) {
      part1 += 3;
    } else if (scores[mapping[you]].beats === mapping[opp]) {
      part1 += 6;
    }

    if (you === 'X') {
      part2 += scores[scores[mapping[opp]].beats].score;
    } else if (you === 'Y') {
      part2 += 3 + scores[mapping[opp]].score;
    } else {
      part2 += 6 + scores[scores[mapping[opp]].loses].score;
    }
  });

  return [part1, part2];
};
