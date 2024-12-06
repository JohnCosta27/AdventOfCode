package day5

import (
	"math"
	"strconv"
	"strings"
)

type Coord struct {
	x int
	y int
}

type coordPairs struct {
	point1 Coord
	point2 Coord
}

func Run(dat []byte) (int, int) {
	
	stringDat := strings.Split(string(dat), "\n")

	coordList := make([]coordPairs, len(stringDat))
	
	for i := 0; i < len(stringDat); i++ {
		
		coords := strings.Split(stringDat[i], " -> ")
		
		firstCoord := strings.Split(coords[0], ",")
		secondCoord := strings.Split(coords[1], ",")
		
		x1, _ := strconv.Atoi(firstCoord[0])
		y1, _ := strconv.Atoi(firstCoord[1])
		x2, _ := strconv.Atoi(secondCoord[0])
		y2, _ := strconv.Atoi(secondCoord[1])
		
		coordList[i] = coordPairs{Coord{x: x1, y: y1}, Coord{x: x2, y: y2}}

	}

	coordMap := make(map[Coord]int)
	part2CoordMap := make(map[Coord]int)

	for _, c := range coordList {
		if (c.point1.x == c.point2.x) {

			lowY := int(math.Min(float64(c.point1.y), float64(c.point2.y)))
			highY := int(math.Max(float64(c.point1.y), float64(c.point2.y)))

			for i := lowY; i <= highY; i++ {
				coordMap[Coord{x: c.point1.x, y: i}] = coordMap[Coord{x: c.point1.x, y: i}] + 1
				part2CoordMap[Coord{x: c.point1.x, y: i}] = part2CoordMap[Coord{x: c.point1.x, y: i}] + 1
			}

		} else if (c.point1.y == c.point2.y) {
				
			lowX := int(math.Min(float64(c.point1.x), float64(c.point2.x)))
			highX := int(math.Max(float64(c.point1.x), float64(c.point2.x)))

			for i := lowX; i <= highX; i++ {
				coordMap[Coord{x: i, y: c.point1.y}] = coordMap[Coord{x: i, y: c.point1.y}] + 1
				part2CoordMap[Coord{x: i, y: c.point1.y}] = part2CoordMap[Coord{x: i, y: c.point1.y}] + 1
			}

		} else {
			
			if c.point1.x < c.point2.x {

				step := 0

				if c.point1.y - c.point2.y > 0 {
					step = -1
				} else {
					step = 1
				}

				counter := c.point1.y
				for i := c.point1.x; i <= c.point2.x; i++ {
					part2CoordMap[Coord{x: i, y: counter}] = part2CoordMap[Coord{x: i, y: counter}] + 1
					counter += step
				}
			} else {

				step := 0

				if c.point2.y - c.point1.y > 0 {
					step = -1
				} else {
					step = 1
				}

				counter := c.point2.y
				for i := c.point2.x; i <= c.point1.x; i++ {
					part2CoordMap[Coord{x: i, y: counter}] = part2CoordMap[Coord{x: i, y: counter}] + 1
					counter += step
				}
			}

		}
	}

	part1 := 0
	part2 := 0

	for _, value := range coordMap {
		if value > 1 {
			part1++
		}
	}

	for _, value := range part2CoordMap {
		if value > 1 {
			part2++
		}
	}

	return part1, part2

}