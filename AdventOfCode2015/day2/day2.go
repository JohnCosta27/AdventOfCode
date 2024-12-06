package main

import (
	"bytes"
	"fmt"
	"io/ioutil"
	"strconv"
	"time"
)

func main() {

	fmt.Println("Day 2")
	start := time.Now()

	dat, err := ioutil.ReadFile("day2.txt")
	if err != nil {
		panic(err)
	}

	lines := bytes.Split(dat, []byte("\n"))
	total := 0
	totalPart2 := 0

	for _, value := range lines {

		splitLine := bytes.Split(value, []byte("x"))
		l, _ := strconv.Atoi(string(splitLine[0]))
		w, _ := strconv.Atoi(string(splitLine[1]))
		h, _ := strconv.Atoi(string(splitLine[2]))

		total += 2*l*w + 2*l*h + 2*w*h + MinOf(l*w, w*h, h*l)
		totalPart2 += MinOf(l*2+w*2, w*2+h*2, h*2+l*2) + l*w*h

	}

	elapsed := time.Since(start)
	fmt.Printf("Part 1: %v %v \n", total, elapsed)
	fmt.Printf("Part 2: %v %v", totalPart2, elapsed)

}

func MinOf(vars ...int) int {
	min := vars[0]

	for _, i := range vars {
		if min > i {
			min = i
		}
	}

	return min
}
