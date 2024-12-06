import { DayFunc } from "..";

type Pos = { x: number; y: number };

export const Day15: DayFunc = (input) => {
  const parsed = input
    .trim()
    .split("\n")
    .map((v) => v.split(" at "))
    .map((v) => [v[1].slice(0, v[1].indexOf(":")), v[2]])
    .map((v) => v.map((i) => i.replaceAll(/[a-z]=/g, "").replaceAll(" ", "")))
    .map((v) => {
      const oneSplit = v[0].split(",");
      const twoSplit = v[1].split(",");
      return [
        [parseInt(oneSplit[0]), parseInt(oneSplit[1])],
        [parseInt(twoSplit[0]), parseInt(twoSplit[1])],
      ];
    });
  const grid: Array<{ sensor: Pos; beacon: Pos; distance: number }> = [];

  let smallestX = 10000;
  let largestX = 0;
  parsed.forEach((i) => {
    const dist = Math.abs(i[0][0] - i[1][0]) + Math.abs(i[0][1] - i[1][1]);
    if (i[0][0] < smallestX) smallestX = i[0][0];
    if (i[1][0] < smallestX) smallestX = i[1][0];

    if (i[0][0] > largestX) largestX = i[0][0];
    if (i[1][0] > largestX) largestX = i[1][0];

    grid.push({
      sensor: {
        x: i[0][0],
        y: i[0][1],
      },
      beacon: {
        x: i[1][0],
        y: i[1][1],
      },
      distance: dist,
    });
  });

  const y = 10;
  let part1 = 0;
  console.log(smallestX);
  console.log(largestX);
  for (let i = smallestX - 10000000; i <= largestX + 10000000; i++) {
    const testPos: Pos = {
      x: i,
      y: y,
    };

    const beaconHere = grid.find(p => p.beacon.x === testPos.x && p.beacon.y === testPos.y);
    if (beaconHere) {
      continue;
    }

    const testPoint = grid.find(p => Math.abs(p.sensor.x - testPos.x) + Math.abs(p.sensor.y - testPos.y) <= p.distance);


    if (testPoint) {
      part1++;
    } 
  }

  return [part1, 0];
};
