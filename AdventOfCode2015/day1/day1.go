package main

import (
	"fmt"
	"io/ioutil"
	"time"
)

func main() {

	fmt.Println("Day 1")
	start := time.Now()

	dat, err := ioutil.ReadFile("day1.txt")
	if err != nil {
		panic(err)
	}

	var floor int64 = 0
	basement := -1

	for i, value := range dat {

		if basement == -1 && floor == -1 {
			basement = i
		}

		if value == 40 {
			floor++
		} else if value == 41 {
			floor--
		}
	}

	elapsed := time.Since(start)
	fmt.Printf("Part 1: %v %v \n", floor, elapsed)
	fmt.Printf("Part 2: %v %v", basement, elapsed)

}
