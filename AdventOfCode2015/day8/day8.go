package main

import (
	"bytes"
	"fmt"
	"io/ioutil"
	"time"
)

type Square struct {
	x int64
	y int64
}

func main() {

	fmt.Println("Day 8")
	start := time.Now()

	dat, err := ioutil.ReadFile("day8.txt")
	if err != nil {
		panic(err)
	}

	lines := bytes.Split(dat, []byte("\n"))

	part2 := 0
	totalCharacters := 0
	realCharacters := 0

	for _, value := range lines {
		line := string(value)
		totalCharacters += len(line)

		newLine := line[1 : len(line)-1]
		currentReal := 0

		for i := 0; i < len(newLine); i++ {
			char := string(newLine[i])
			if char == `\` {
				nextChar := string(newLine[i+1])
				if nextChar == "x" {
					i = i + 2
				} else if nextChar == `"` || nextChar == `\` {
					i++
					currentReal++
				}
			} else {
				currentReal++
			}
		}
		realCharacters += currentReal

		currentPart2 := 0

		for i := 0; i < len(line); i++ {
			char := string(line[i])
			if char == `"` || char == `\` {
				currentPart2 += 2
			} else {
				currentPart2++
			}
		}
		//Double quotes around the string
		currentPart2 += 2
		part2 += currentPart2

	}

	elapsed := time.Since(start)
	fmt.Printf("Part 1: %v %v \n", totalCharacters-realCharacters, elapsed)
	fmt.Printf("Part 2: %v %v \n", part2-totalCharacters, elapsed)

}

func compare(slice1 []byte, slice2 []byte) bool {
	for i := 0; i < len(slice1) && i < len(slice2); i++ {
		if slice1[i] != slice2[i] {
			return false
		}
	}
	return true
}
