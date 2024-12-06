package main

import (
	"crypto/md5"
	"fmt"
	"io/ioutil"
	"strconv"
	"time"
)

type Coords struct {
	x int
	y int
}

func main() {

	fmt.Println("Day 3")
	start := time.Now()

	dat, err := ioutil.ReadFile("day4.txt")
	if err != nil {
		panic(err)
	}
	input := string(dat)

	part1 := ""
	var hash [16]byte
	for i := 1; part1 == ""; i++ {
		hashString := input + strconv.Itoa(i)
		hash = md5.Sum([]byte(hashString))
		if hash[0] == 0x00 && hash[1] == 0x00 && hash[2] <= 0x0f {
			part1 = hashString
		}
	}

	elapsed := time.Since(start)
	fmt.Printf("Part 1: %v %v \n", part1, elapsed)
	start = time.Now()

	part2 := ""
	for i := 1; part2 == ""; i++ {
		hashString := input + strconv.Itoa(i)
		hash = md5.Sum([]byte(hashString))
		if hash[0] == 0x00 && hash[1] == 0x00 && hash[2] == 0x00 {
			part2 = hashString
		}
	}

	elapsed = time.Since(start)
	fmt.Printf("Part 2: %v %v", part2, elapsed)

}
