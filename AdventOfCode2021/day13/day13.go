package day13

import (
	"bytes"
	"fmt"
	"strconv"
	"strings"
)

type coord struct {
	x int
	y int
} 

func Run(dat []byte) (int, int) {

	splitBytes := bytes.Split(dat, []byte{10, 10})
	stringCoords := strings.Split(string(splitBytes[0]), "\n")
	stringInstructions := strings.Split(string(splitBytes[1]), "\n")
	
	coordMap := make(map[coord]int)
	
	for _, line := range stringCoords {
		splitLine := strings.Split(line, ",")
		x, _ := strconv.Atoi(splitLine[0])
		y, _ := strconv.Atoi(splitLine[1])
		coordMap[coord{x: x, y: y}] = coordMap[coord{x: x, y: y}] + 1
	}	

	part1 := 0
	part2 := 0

	for i := 0; i < len(stringInstructions); i++ {
		splitInstruction := strings.Split(stringInstructions[i], "fold along ")
		number, _ := strconv.Atoi(string(splitInstruction[1][2:]))
		if splitInstruction[1][0] == 'y' {

			for k, _ := range coordMap {
				if k.y > number {
          delete(coordMap, k)
					coordMap[coord{x: k.x, y: k.y - ((k.y - number) * 2)}] += 1 
				}
			}

		} else {

			for k, _ := range coordMap {
				if k.x > number {
          delete(coordMap, k)
					coordMap[coord{x: k.x - ((k.x - number) * 2), y: k.y}] = 1
				}
			}

		}

		if (i == 0) {
			for k, _ := range coordMap {
				if coordMap[k] > 0 {
					part1++
				}
			}
		}

	}

	highestX := 0
	highestY := 0
	for k, _ := range coordMap {
		if k.x > highestX {
			highestX = k.x
		}
		if k.y > highestY {
			highestY = k.y
		}
	}
	

	for i := 0; i <= highestY; i++ {
		for j := 0; j <= highestX; j++ {

			if coordMap[coord{x: j, y: i}] > 0 {
				fmt.Print("#")
			} else {
				fmt.Print(".")
			}
		}
		fmt.Println()
	}
	
	return part1, part2
}