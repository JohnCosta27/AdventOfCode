package main

import (
	"bytes"
	"fmt"
	"io/ioutil"
	"strconv"
	"strings"
	"time"
)

func main() {
	fmt.Println("Day 13")
	start := time.Now()

	dat, err := ioutil.ReadFile("day14.txt")
	if err != nil {
		panic(err)
	}
	lines := bytes.Split(dat, []byte("\n"))

	part1 := 0
	total := 2503
	for _, line := range lines {
		stringLine := string(line)
		splitLine := strings.Split(stringLine, " ")

		v, _ := strconv.Atoi(splitLine[3])
		s, _ := strconv.Atoi(splitLine[6])
		r, _ := strconv.Atoi(splitLine[13])

		currentDistance := (total / (s + r)) * v * s
		remaining := total % (s + r)
		if remaining >= s {
			currentDistance += v * s
		} else {
			currentDistance += v * remaining
		}
		if currentDistance > part1 {
			part1 = currentDistance
		}
	}

	elapsed := time.Since(start)
	fmt.Printf("Part 1: %v %v \n", part1, elapsed)

	start = time.Now()

	horses := make(map[int]int)
	for i := 1; i <= total; i++ {

		longest := 0
		fastestHorse := 0
		for index, line := range lines {
			stringLine := string(line)
			splitLine := strings.Split(stringLine, " ")

			v, _ := strconv.Atoi(splitLine[3])
			s, _ := strconv.Atoi(splitLine[6])
			r, _ := strconv.Atoi(splitLine[13])

			currentDistance := (i / (s + r)) * v * s
			remaining := i % (s + r)
			if remaining >= s {
				currentDistance += v * s
			} else {
				currentDistance += v * remaining
			}
			if currentDistance > longest {
				longest = currentDistance
				fastestHorse = index
			}
		}

		horses[fastestHorse] = horses[fastestHorse] + 1

	}

	fastest := 0
	for _, value := range horses {
		if value > fastest {
			fastest = value
		}
	}

	elapsed = time.Since(start)
	fmt.Printf("Part 2: %v %v \n", fastest, elapsed)

}
