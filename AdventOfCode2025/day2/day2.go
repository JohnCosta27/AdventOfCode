package main

import (
	"fmt"
	"math"
	"os"
	"strconv"
	"strings"
)

type Range struct {
	Lower int
	Upper int
}

// 10 = 1, 2, 5
func factorsWithoutNum(num int) []int {
	factors := make([]int, 0)

	for i := 1; i < num; i++ {
		if num%i == 0 {
			factors = append(factors, i)
		}
	}

	return factors
}

func isSliceAllEqual(s []int) bool {
	if len(s) == 0 {
		return true
	}

	firstItem := s[0]
	for _, i := range s {
		if firstItem != i {
			return false
		}
	}

	return true
}

func testNumber(num int) bool {
	digits := int(math.Floor(math.Log10(float64(num)))) + 1

	factors := factorsWithoutNum(digits)
	for _, chunkSize := range factors {
		nums := make([]int, 0)
		for i := chunkSize; i <= digits; i += chunkSize {
			divisor := int(math.Pow10(i))
			remainderDivisor := int(math.Pow10(i - chunkSize))

			remainder := num % divisor
			remainder = remainder / remainderDivisor

			nums = append(nums, remainder)
		}

		if isSliceAllEqual(nums) {
			return true
		}
	}

	return false
}

func main() {
	lines, err := os.ReadFile("./input.txt")
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}

	trimmedString := strings.TrimSuffix(string(lines), "\n")

	splitLines := strings.Split(trimmedString, ",")

	ranges := make([]Range, len(splitLines))
	for i, line := range splitLines {
		stringRange := strings.Split(line, "-")

		lower, errLower := strconv.Atoi(stringRange[0])
		upper, errUpper := strconv.Atoi(stringRange[1])

		if errLower != nil || errUpper != nil {
			fmt.Println(errLower, errUpper)
			os.Exit(1)
		}

		ranges[i] = Range{lower, upper}
	}

	// log10 -> find number of digits.

	part1 := 0
	part2 := 0

	for _, r := range ranges {
		for i := r.Lower; i <= r.Upper; i++ {
			base10 := math.Log10(float64(i))
			exp := int(math.Floor(base10)) + 1

			divisor := int(math.Pow10(exp / 2))

			upperHalf := i / divisor
			lowerHalf := i % divisor

			if upperHalf == lowerHalf {
				part1 += i
			}

			if testNumber(i) {
				part2 += i
			}
		}
	}

	fmt.Printf("Part 1: %d\n", part1)
	fmt.Printf("Part 2: %d\n", part2)
}
