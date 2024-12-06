package main

import (
	"bytes"
	"fmt"
	"io/ioutil"
	"strconv"
	"time"
)

type Square struct {
	x int64
	y int64
}

func main() {

	fmt.Println("Day 6")
	start := time.Now()

	dat, err := ioutil.ReadFile("day6.txt")
	if err != nil {
		panic(err)
	}

	lines := bytes.Split(dat, []byte("\n"))
	lights := make(map[Square]bool)
	lights2 := make(map[Square]int64)

	SwitchTheLights(lights, false, false, 0, 0, 1000, 1000)

	part1 := 0
	var part2 int64 = 0

	for _, value := range lines {

		words := bytes.Split(value, []byte(" "))
		if len(words) == 4 {

			start := bytes.Split(words[1], []byte(","))
			end := bytes.Split(words[3], []byte(","))

			startX, _ := strconv.Atoi(string(start[0]))
			startY, _ := strconv.Atoi(string(start[1]))
			endX, _ := strconv.Atoi(string(end[0]))
			endY, _ := strconv.Atoi(string(end[1]))

			SwitchTheLights(lights, false, true, int64(startX), int64(startY), int64(endX), int64(endY))
			SwitchTheLights2(lights2, false, true, int64(startX), int64(startY), int64(endX), int64(endY))

		} else {

			start := bytes.Split(words[2], []byte(","))
			end := bytes.Split(words[4], []byte(","))

			startX, _ := strconv.Atoi(string(start[0]))
			startY, _ := strconv.Atoi(string(start[1]))
			endX, _ := strconv.Atoi(string(end[0]))
			endY, _ := strconv.Atoi(string(end[1]))

			SwitchTheLights(lights, compare(words[1], []byte("on")), false, int64(startX), int64(startY), int64(endX), int64(endY))
			SwitchTheLights2(lights2, compare(words[1], []byte("on")), false, int64(startX), int64(startY), int64(endX), int64(endY))

		}

	}

	for _, v := range lights {
		if v {
			part1++
		}
	}

	for _, v := range lights2 {
		part2 += v
	}

	elapsed := time.Since(start)
	fmt.Printf("Part 1: %v %v \n", part1, elapsed)
	fmt.Printf("Part 2: %v %v \n", part2, elapsed)

}

func SwitchTheLights(lights map[Square]bool, state bool, toggle bool, startX int64, startY int64, endX int64, endY int64) {

	for i := startX; i <= endX; i++ {
		for j := startY; j <= endY; j++ {
			if toggle {
				lights[Square{x: i, y: j}] = !lights[Square{x: i, y: j}]
			} else {
				lights[Square{x: i, y: j}] = state
			}
		}
	}

}

func SwitchTheLights2(lights map[Square]int64, state bool, toggle bool, startX int64, startY int64, endX int64, endY int64) {

	for i := startX; i <= endX; i++ {
		for j := startY; j <= endY; j++ {

			var brighness int64 = lights[Square{x: i, y: j}]
			if toggle {
				lights[Square{x: i, y: j}] = brighness + 2
			} else {

				if state {
					lights[Square{x: i, y: j}] = brighness + 1
				} else {
					lights[Square{x: i, y: j}] = brighness - 1
					if lights[Square{x: i, y: j}] < 0 {
						lights[Square{x: i, y: j}] = 0
					}
				}

			}
		}
	}

}

func compare(slice1 []byte, slice2 []byte) bool {
	for i := 0; i < len(slice1) && i < len(slice2); i++ {
		if slice1[i] != slice2[i] {
			return false
		}
	}
	return true
}
