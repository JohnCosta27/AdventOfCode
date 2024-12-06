package main

import (
	"fmt"
	"io/ioutil"
	"time"

	"johncosta.tech/AdventOfCode2021/day14"
)

func main() {

	fmt.Println("---------------------------------------")
	fmt.Println("Advent of Code 2021")
	fmt.Println("---------------------------------------")

	start := time.Now()

	/*day1input, _ := ioutil.ReadFile("day1/day1.txt")
	day2input, _ := ioutil.ReadFile("day2/day2.txt")
	day3input, _ := ioutil.ReadFile("day3/day3.txt")
	day4input, _ := ioutil.ReadFile("day4/day4.txt")
	day5input, _ := ioutil.ReadFile("day5/day5.txt")
	day6input, _ := ioutil.ReadFile("day6/day6.txt")
	day7input, _ := ioutil.ReadFile("day7/day7.txt")
	day8input, _ := ioutil.ReadFile("day8/day8.txt")
	day13input, _ := ioutil.ReadFile("day13/day13.txt")*/
	day14input, _ := ioutil.ReadFile("day14/day14.txt")

	dayTime := time.Now()
	/*day1part1, day1part2 := day1.Run(day1input)
	printAnswers(1, time.Since(dayTime), day1part1, day1part2)

	day2part1, day2part2 := day2.Run(day2input)
	printAnswers(2, time.Since(dayTime), day2part1, day2part2)

	day3part1, day3part2 := day3.Run(day3input)
	printAnswers(3, time.Since(dayTime), day3part1, day3part2)

	day4part1, day4part2 := day4.Run(day4input)
	printAnswers(4, time.Since(dayTime), day4part1, day4part2)

	day5part1, day5part2 := day5.Run(day5input)
	printAnswers(5, time.Since(dayTime), day5part1, day5part2)

	day6part1, day6part2 := day6.Run(day6input)
	printAnswers(6, time.Since(dayTime), day6part1, day6part2)

	day7part1, day7part2 := day7.Run(day7input)
	printAnswers(7, time.Since(dayTime), day7part1, day7part2)

	day8part1, day8part2 := day6.Run(day8input)
	printAnswers(8, time.Since(dayTime), day8part1, day8part2)

	day13part1, _ := day13.Run(day13input)
	printAnswers(13, time.Since(dayTime), day13part1, 0)*/

	day14part1, day14part2 := day14.Run(day14input)
	printAnswers(8, time.Since(dayTime), day14part1, day14part2)

	elapsed := time.Since(start)

	fmt.Printf("Total Time taken: %v \n", elapsed)
	fmt.Println("---------------------------------------")

}

func printAnswers(day int, time time.Duration, part1 int64, part2 int64) {
	fmt.Println("---------------------------------------")
	fmt.Printf("Day %v \n", day)
	fmt.Printf("Part 1: %v \n", part1)
	fmt.Printf("Part 2: %v \n", part2)
	fmt.Printf("Time Taken: %v \n", time)
	fmt.Println("---------------------------------------")
}
