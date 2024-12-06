package day7

import (
	"fmt"
	"math"
	"sort"
	"strconv"
	"strings"
)

func Run(dat []byte) (int, int) {
	
	fmt.Println("Day 7")
	
	stringDat := strings.Split(string(dat), ",")
	
	crabList := make([]int, len(stringDat))
	for i, value := range stringDat {
		num, _ := strconv.Atoi(value)
		crabList[i] = num
	}

	sort.Ints(crabList)

	median := crabList[len(crabList) / 2]

	lowest := 100000000000
	part2lowest := 10000000000000

	for i := median - 200; i <= median + 200; i++ {

		difference := 0
		part2difference := 0

		for _, n := range crabList {
			currentDifference := math.Abs(float64(i) - float64(n))
			difference += int(currentDifference)
			part2difference += int((currentDifference / 2) * (currentDifference + 1))
		}

		if difference < lowest {
			lowest = difference
		}

		if part2difference < part2lowest {
			part2lowest = part2difference
		}

	}

	return lowest, part2lowest

}