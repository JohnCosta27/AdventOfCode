package main

import (
	"bytes"
	"fmt"
	"io/ioutil"
	"strconv"
	"strings"
	"time"
)

type Combination struct {
	subject string
	nextTo  string
}

type Average struct {
	person1 string
	person2 string
	average int
}

func main() {
	fmt.Println("Day 13")
	start := time.Now()

	dat, err := ioutil.ReadFile("day13.txt")
	if err != nil {
		panic(err)
	}
	lines := bytes.Split(dat, []byte("\n"))
	combinationMap := make(map[Combination]int)
	people := make([]string, 0)

	for _, line := range lines {
		stringLine := string(line)
		stringLine = stringLine[:len(stringLine)-1]
		lineWordArray := strings.Split(string(stringLine), " ")
		gained, _ := strconv.Atoi(lineWordArray[3])

		if !contains(people, lineWordArray[0]) {
			people = append(people, lineWordArray[0])
		}

		if lineWordArray[2] == "lose" {
			gained = -gained
		}
		combinationMap[Combination{subject: lineWordArray[0], nextTo: lineWordArray[10]}] = gained
	}

	averageCombinations := make([]Average, 0)
	for _, person := range people {

		for i := 0; i < len(people); i++ {
			nextPerson := people[i]
			if nextPerson != person {
				average := combinationMap[Combination{subject: person, nextTo: nextPerson}] + combinationMap[Combination{subject: nextPerson, nextTo: person}]
				averageCombinations = append(averageCombinations, Average{person1: person, person2: nextPerson, average: average})
			}
		}

	}

	startingPerson := people[0]
	remaining := make([]string, 0)
	for _, value := range people {
		if value != startingPerson {
			remaining = append(remaining, value)
		}
	}

	part1 := travellingSalesMan(averageCombinations, startingPerson, startingPerson, remaining)

	elapsed := time.Since(start)
	fmt.Printf("Part 1: %v %v \n", part1, elapsed)

	start = time.Now()

	for _, person := range people {
		averageCombinations = append(averageCombinations, Average{person1: "me", person2: person, average: 0})
		averageCombinations = append(averageCombinations, Average{person1: person, person2: "me", average: 0})
	}

	people = append(people, "me")
	startingPerson = people[0]
	remaining = make([]string, 0)
	for _, value := range people {
		if value != startingPerson {
			remaining = append(remaining, value)
		}
	}

	part2 := travellingSalesMan(averageCombinations, startingPerson, startingPerson, remaining)
	elapsed = time.Since(start)
	fmt.Printf("Part 2: %v %v \n", part2, elapsed)

}

func travellingSalesMan(averages []Average, startingPerson string, currentPerson string, remainingPeople []string) int {

	//*Needs to return to the beginning
	if len(remainingPeople) == 0 {
		return getAverage(averages, startingPerson, currentPerson)
	} else {

		distances := make([]int, 0)
		for _, person := range remainingPeople {
			newRemaining := make([]string, 0)
			for _, p := range remainingPeople {
				if p != person {
					newRemaining = append(newRemaining, p)
				}
			}
			distances = append(distances, getAverage(averages, currentPerson, person)+travellingSalesMan(averages, startingPerson, person, newRemaining))
		}
		max := 0
		for _, value := range distances {
			if value > max {
				max = value
			}
		}
		return max
	}

}

func contains(array []string, person string) bool {
	for _, v := range array {
		if v == person {
			return true
		}
	}
	return false
}

func getAverage(array []Average, person1 string, person2 string) int {
	for _, p := range array {
		if p.person1 == person1 && p.person2 == person2 {
			return p.average
		}
	}
	return 0
}
