package main

import (
	"fmt"
	"strconv"
	"time"
)

func main() {

	fmt.Println("Day 9")
	start := time.Now()

	inputString := "1113122113"
	input := []int64{}

	for _, c := range inputString {
		stringChar, _ := strconv.Atoi(string(c))
		input = append(input, int64(stringChar))
	}

	//Change 40 to 50 for part 2
	for rounds := 0; rounds < 40; rounds++ {

		lastNum := input[0]
		var counter int64 = 1

		newNumbers := []int64{}

		for i := 1; i < len(input); i++ {
			if input[i] != lastNum {
				newNumbers = append(newNumbers, counter)
				newNumbers = append(newNumbers, lastNum)
				counter = 1
				lastNum = input[i]
			} else {
				counter++
			}
		}
		newNumbers = append(newNumbers, counter)
		newNumbers = append(newNumbers, lastNum)
		input = newNumbers
	}

	elapsed := time.Since(start)
	fmt.Printf("Part 1: %v %v \n", len(input), elapsed)
	fmt.Printf("Part 2: %v %v \n", len(input), elapsed)

}
