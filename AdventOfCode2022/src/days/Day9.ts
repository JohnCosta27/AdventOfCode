import { DayFunc } from "..";

type Pos = { x: number; y: number };

// Returns the non square rooted distance
const CalcDist = (a: Pos, b: Pos) => {
  return (a.x - b.x) ** 2 + (a.y - b.y) ** 2;
};

const CalcVisited = (snake: Pos[], parsed: [string, number][]): Record<string, number> => {

  const visited: Record<string, number> = {};
  visited[JSON.stringify(snake[1])] = 1;

  parsed.forEach(([direction, num]) => {
    for (let i = 0; i < num; i++) {
      if (direction === "R") snake[0].x++;
      else if (direction === "L") snake[0].x--;
      else if (direction === "U") snake[0].y++;
      else if (direction === "D") snake[0].y--;

      for (let j = 1; j < snake.length; j++) {
        const t = snake[j];
        const h = snake[j - 1]
        const dist = CalcDist(h, t);
        if (dist === 4) {
          if (t.x === h.x) {
            t.y += (h.y < t.y) ? -1 : 1;
          } else if (t.y === h.y) {
            t.x += (h.x < t.x) ? -1 : 1;
          }
        } else if (dist === 5 || dist === 8) {
          t.x += (h.x > t.x) ? 1 : -1;
          t.y += (h.y > t.y) ? 1 : -1;
        }
      }

      const tailString = JSON.stringify(snake[snake.length - 1]);
      if (tailString in visited) {
        visited[tailString] = visited[tailString] + 1;
      } else {
        visited[tailString] = 1;
      }
    }
  });

  return visited;
}

export const Day9: DayFunc = (input) => {
  const parsed: [string, number][] = input
    .trim()
    .split("\n")
    .map((v) => v.split(" "))
    .map(([a, b]) => [a, parseInt(b)]);

  // 0th index is the head;
  const part1Snake: Pos[] = [
    { x: 0, y: 0 },
    { x: 0, y: 0 },
  ];
  const part2Snake: Pos[] = [];
  for (let i = 0; i < 10; i++) {
    part2Snake.push({x: 0, y: 0});
  }

  const part1 = CalcVisited(part1Snake, parsed)
  const part2 = CalcVisited(part2Snake, parsed)

  return [Object.keys(part1).length, Object.keys(part2).length];
};
