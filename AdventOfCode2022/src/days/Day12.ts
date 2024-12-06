import { DayFunc } from "..";

const FunnyCharCode = (input: string): number => {
  if (input === "S") return "a".charCodeAt(0);
  if (input === "E") return "z".charCodeAt(0);
  return input.charCodeAt(0);
};

const IsOk = (
  input: string[][],
  edges: Record<string, string[]>,
  a: [number, number],
  b: [number, number]
) => {
  if (!edges[`${a[0]},${a[1]}`]) {
    edges[`${a[0]},${a[1]}`] = [];
  }
  const c = edges[`${a[0]},${a[1]}`];
  if (FunnyCharCode(input[a[0]][a[1]]) - FunnyCharCode(input[b[0]][b[1]]) >= -1) {
    c.push(`${b[0]},${b[1]}`);
  }
};

export const Day12: DayFunc = (input) => {
  const parsed = input
    .trim()
    .split("\n")
    .map((i) => i.split(""));

  const edges: Record<string, string[]> = {};
  const visited: { letter: string; node: string; visited: boolean }[] = [];

  for (let i = 0; i < parsed.length; i++) {
    for (let j = 0; j < parsed[0].length; j++) {
      visited.push({
        letter: parsed[i][j],
        node: `${i},${j}`,
        visited: false,
      });
      if (i > 0 && j > 0 && i < parsed.length - 1 && j < parsed[0].length - 1) {
        IsOk(parsed, edges, [i, j], [i + 1, j]);
        IsOk(parsed, edges, [i, j], [i - 1, j]);
        IsOk(parsed, edges, [i, j], [i, j + 1]);
        IsOk(parsed, edges, [i, j], [i, j - 1]);
      } else if (i > 0 && j > 0 && i < parsed.length - 1) {
        IsOk(parsed, edges, [i, j], [i + 1, j]);
        IsOk(parsed, edges, [i, j], [i - 1, j]);
        IsOk(parsed, edges, [i, j], [i, j - 1]);
      } else if (i > 0 && j > 0 && j < parsed[0].length - 1) {
        IsOk(parsed, edges, [i, j], [i - 1, j]);
        IsOk(parsed, edges, [i, j], [i, j + 1]);
        IsOk(parsed, edges, [i, j], [i, j - 1]);
      } else if (i === 0 && j > 0 && j < parsed[0].length - 1) {
        IsOk(parsed, edges, [i, j], [i + 1, j]);
        IsOk(parsed, edges, [i, j], [i, j + 1]);
        IsOk(parsed, edges, [i, j], [i, j - 1]);
      } else if (j === 0 && i > 0 && i < parsed.length - 1) {
        IsOk(parsed, edges, [i, j], [i + 1, j]);
        IsOk(parsed, edges, [i, j], [i - 1, j]);
        IsOk(parsed, edges, [i, j], [i, j + 1]);
      }
    }
  }

  IsOk(parsed, edges, [0, 0], [0, 1]);
  IsOk(parsed, edges, [0, 0], [1, 0]);

  IsOk(
    parsed,
    edges,
    [parsed.length - 1, parsed[0].length - 1],
    [parsed.length - 1, parsed[0].length - 2]
  );
  IsOk(
    parsed,
    edges,
    [parsed.length - 1, parsed[0].length - 1],
    [parsed.length - 2, parsed[0].length - 1]
  );

  IsOk(parsed, edges, [parsed.length - 1, 0], [parsed.length - 2, 0]);
  IsOk(parsed, edges, [parsed.length - 1, 0], [parsed.length - 1, 1]);

  IsOk(parsed, edges, [0, parsed[0].length - 1], [0, parsed[0].length - 2]);
  IsOk(parsed, edges, [0, parsed[0].length - 1], [1, parsed[0].length - 1]);

  const startNode = visited.find((v) => v.letter === "S");

  const part1 = BFS(startNode.node, edges, visited);

  const part2 = visited.filter(v => v.letter === 'a').map(n => BFS(n.node, edges, visited));

  return [part1, Math.min(...part2)];
};

const BFS = (
  currentNode: string,
  edges: Record<string, string[]>,
  visited: { letter: string; node: string; visited: boolean }[]
): number => {
  const q: Array<{ letter: string; node: string; visited: boolean } | null> =
    [];

  const marked = new Set();

  const c = visited.find((v) => v.node === currentNode);
  q.push(c);

  const depthQueue = [0];

  marked.add(c.node);

  while (q.length > 0) {
    const head = q.shift();
    const level = depthQueue.shift();

    marked.add(head.node);

    if (head.letter === "E") {
      return level;
    }
    
    edges[head.node].filter(p => !marked.has(p)).forEach(v => {
      const n = visited.find(i => i.node === v);
      marked.add(n.node);
      q.push(n);
      depthQueue.push(level + 1);
    });
  }

  return 10000000;
};
