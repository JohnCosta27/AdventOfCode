package day6

import (
	"strconv"
	"strings"
)

func Run(dat []byte) (int, int) {

	stringDat := string(dat)

	fish := strings.Split(stringDat, ",")

	/**
	 * We do not need to keep track of every fish,
	 * We only need to keep track of the number of fish at a certain age.
	 * Which is much more efficient than an exponentially increasing array.
	 */
	fishMap := make(map[int]int)

	part2FishMap := make(map[int]int)

	for _, value := range fish {
		age, _ := strconv.Atoi(value)
		fishMap[age] = fishMap[age]  + 1
		part2FishMap[age] = part2FishMap[age] + 1
	}

	for day := 1; day <= 80; day++ {

		readyFish := fishMap[0]

		for i := 1; i <= 8; i++ {
			fishMap[i - 1] = fishMap[i]
		}

		fishMap[6] = fishMap[6] + readyFish
		fishMap[8] = readyFish

	}

	var part1 int = 0
	for _, num := range fishMap {
		part1 += num
	}

	//-------------------

	for day := 1; day <= 256; day++ {

		readyFish := part2FishMap[0]

		for i := 1; i <= 8; i++ {
			part2FishMap[i - 1] = part2FishMap[i]
		}

		part2FishMap[6] = part2FishMap[6] + readyFish
		part2FishMap[8] = readyFish

	}

	var part2 int = 0
	for _, num := range part2FishMap {
		part2 += num
	}

	return part1, part2

}