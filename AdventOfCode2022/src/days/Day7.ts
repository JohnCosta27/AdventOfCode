import { DayFunc } from "..";

type Node = {
  name: string;
  type: "file" | "dir";
  size: number;
};

type Files = {
  [key: string]: { size: number; children: Node[] };
};

const totalItems: Files = {};

const CalcSize = (dirName: string): number => {
  const dir = totalItems[dirName];
  let size = 0;
  for (const c of dir.children) {
    if (c.type === "file") {
      size += c.size;
    } else {
      size += CalcSize(c.name);
    }
  }
  dir.size = size;
  return size;
};

export const Day7: DayFunc = (input) => {
  const parsed = input
    .trim()
    .split("\n")
    .filter((i) => i !== "$ ls").slice(1);

  let path: string[] = [];
  let items: Node[] = [];

  parsed.forEach((i) => {
    let pathReduced = "/";
    for (const c of path) {
      pathReduced += c + "/";
    }
    if (i === "$ cd ..") {
      if (!(pathReduced in totalItems)) {
        totalItems[pathReduced] = { size: 0, children: [...items] };
        items = [];
      }
      path.pop();
    } else if (i.charAt(0) === "$") {
      if (!(pathReduced in totalItems)) {
        totalItems[pathReduced] = { size: 0, children: [...items] };
        items = [];
      }
      path.push(i.split(" ")[2]);
    } else {
      const s = i.split(" ");
      items.push({
        type: s[0] === "dir" ? "dir" : "file",
        size: s[0] === "dir" ? 0 : parseInt(s[0]),
        name: s[0] === "dir" ? pathReduced + s[1] + "/" : s[1],
      });
    }
  });

  let pathReduced = "/";
  for (const c of path) {
    pathReduced += c + "/";
  }
  if (!(pathReduced in totalItems)) {
    totalItems[pathReduced] = { size: -1, children: [...items] };
    items = [];
  }

  CalcSize("/");
  const part1 = Object.values(totalItems).reduce((p, n) => {
    if (n.size <= 100000) {
      return p + n.size;
    }
    return p;
  }, 0);

  const usedSize = totalItems["/"].size;
  const toFree = 30000000 - (70000000 - usedSize);

  const part2 = Object.entries(totalItems).map(v => {
    if (v[1].size > toFree) {
      return v[1].size;
    }
  }).filter(v => v).sort()[0];

  return [part1, part2];
};
