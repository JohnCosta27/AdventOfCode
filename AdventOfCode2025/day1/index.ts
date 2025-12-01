const file = Bun.file("./input.txt");
const content = await file.text();

const turns = content
	.trim()
	.split("\n")
	.map((l) => Number(l[0] === "L" ? -1 : 1) * Number(l.slice(1)));

let part1 = 0;
let part2 = 0;
let position = 50;

for (const turn of turns) {
	const effectiveTurn = turn % 100;
	const boundToAdd = position === 0 ? 0 : 1;

	position += effectiveTurn;

	if (position > 99) {
		position = position - 100;
		part2 += boundToAdd;
	} else if (position < 0) {
		position = 100 + position;
		part2 += boundToAdd;
	} else if (position === 0) {
		part2 += boundToAdd;
	}

	const fullTurns = Math.floor(Math.abs(turn) / 100);
	part2 += fullTurns;

	if (position === 0) {
		part1++;
	}
}

console.log("Part 1: ", part1);
console.log("Part 2: ", part2);
