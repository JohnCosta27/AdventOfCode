package main

import (
	"fmt"
	"io/ioutil"
	"time"
)

type Coords struct {
	x int
	y int
}

func main() {

	fmt.Println("Day 3")
	start := time.Now()

	dat, err := ioutil.ReadFile("day3.txt")
	if err != nil {
		panic(err)
	}

	position := Coords{x: 0, y: 0}
	visited := make(map[Coords]int)
	visited[position] = 1

	for _, value := range dat {
		solve(visited, &position, value)
	}

	elapsed := time.Since(start)
	fmt.Printf("Part 1: %v %v \n", len(visited), elapsed)

	start = time.Now()
	position = Coords{x: 0, y: 0}
	visited = make(map[Coords]int)
	visited[position] = 1

	for i := 0; i < len(dat); i = i + 2 {
		solve(visited, &position, dat[i])
	}

	position.x = 0
	position.y = 0

	for i := 1; i < len(dat); i = i + 2 {
		solve(visited, &position, dat[i])
	}

	fmt.Printf("Part 2: %v %v", len(visited), elapsed)

}

func solve(visited map[Coords]int, position *Coords, value byte) {
	if value == []byte("<")[0] {
		position.x--
		visited[*position]++
	} else if value == []byte(">")[0] {
		position.x++
		visited[*position]++
	} else if value == []byte("^")[0] {
		position.y++
		visited[*position]++
	} else if value == []byte("v")[0] {
		position.y--
		visited[*position]++
	}
}
