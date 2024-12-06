package main

import (
	"bytes"
	"fmt"
	"io/ioutil"
	"time"
)

func main() {

	fmt.Println("Day 5")
	start := time.Now()

	dat, err := ioutil.ReadFile("day5.txt")
	if err != nil {
		panic(err)
	}

	lines := bytes.Split(dat, []byte("\n"))
	part1 := 0
	part2 := 0

	for _, value := range lines {

		vowels := 0
		twiceInARow := false
		forbiddenPhrases := false

		for i := 0; i < len(value); i++ {
			current := value[i]
			if current == []byte("a")[0] || current == []byte("e")[0] || current == []byte("i")[0] || current == []byte("o")[0] || current == []byte("u")[0] {
				vowels++
			}

			if i != 0 {
				if value[i-1] == value[i] {
					twiceInARow = true
				}

				last2 := []byte{value[i-1], value[i]}
				if compare(last2, []byte("ab")) || compare(last2, []byte("cd")) || compare(last2, []byte("pq")) || compare(last2, []byte("xy")) {
					forbiddenPhrases = true
					break
				}

			}

		}

		if !forbiddenPhrases {
			if twiceInARow && vowels >= 3 {
				part1++
			}
		}

	}

	elapsed := time.Since(start)
	fmt.Printf("Part 1: %v %v \n", part1, elapsed)

	start = time.Now()

	for _, value := range lines {

		repeatedPair := false
		repeatedLetterWithGap := false

		var pairs [][]byte
		for i := 0; i < len(value)-1; i++ {
			pairs = append(pairs, value[i:i+2])
		}

		for i := 0; i < len(pairs)-1; i++ {
			for j := i + 2; j < len(pairs); j++ {
				if compare(pairs[i], pairs[j]) {
					repeatedPair = true
					break
				}
			}
		}

		for i := 0; i < len(value)-2; i++ {
			if value[i] == value[i+2] {
				repeatedLetterWithGap = true
				break
			}
		}

		if repeatedLetterWithGap && repeatedPair {
			part2++
		}
	}

	elapsed = time.Since(start)
	fmt.Printf("Part 2: %v %v", part2, elapsed)

}

func compare(slice1 []byte, slice2 []byte) bool {
	for i := 0; i < len(slice1) && i < len(slice2); i++ {
		if slice1[i] != slice2[i] {
			return false
		}
	}
	return true
}
