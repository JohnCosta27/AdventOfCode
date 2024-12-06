package main

import (
	"bytes"
	"fmt"
	"io/ioutil"
	"strconv"
	"strings"
)

func main() {

	fmt.Println("Day 15")
	dat, err := ioutil.ReadFile("day15.txt")
	if err != nil {
		panic(err)
	}

	lines := bytes.Split(dat, []byte("\n"))
	ingredients := make([][]int, 4)
	for i := range ingredients {
		ingredients[i] = make([]int, 5)
	}

	for index, line := range lines {

		stringLine := string(line)
		splitString := strings.Split(stringLine, " ")
		ingredients[index][0], _ = strconv.Atoi(strings.TrimRight(splitString[2], ","))
		ingredients[index][1], _ = strconv.Atoi(strings.TrimRight(splitString[4], ","))
		ingredients[index][2], _ = strconv.Atoi(strings.TrimRight(splitString[6], ","))
		ingredients[index][3], _ = strconv.Atoi(strings.TrimRight(splitString[8], ","))
		ingredients[index][4], _ = strconv.Atoi(splitString[10])

	}

	best := 0
	part2 := 0
	for a := 0; a <= 100; a++ {
		for b := 0; b <= 100-a; b++ {
			for c := 0; c <= 100-a-b; c++ {
				for d := 0; d <= 100-a-b-c; d++ {

					calculation := calc_cookie(ingredients, a, b, c, d)
					totalCalories := a*ingredients[0][4] + b*ingredients[1][4] + c*ingredients[2][4] + d*ingredients[3][4]

					if calculation > best {
						best = calculation
					}

					if totalCalories == 500 && calculation > part2 {
						part2 = calculation
					}

				}
			}
		}
	}

	fmt.Println(best)
	fmt.Println(part2)

}

func calc_cookie(ingredients [][]int, sprinkles int, peanut int, frosting int, sugar int) int {

	capacity := sprinkles*ingredients[0][0] +
		peanut*ingredients[1][0] +
		frosting*ingredients[2][0] +
		sugar*ingredients[3][0]

	durability := sprinkles*ingredients[0][1] +
		peanut*ingredients[1][1] +
		frosting*ingredients[2][1] +
		sugar*ingredients[3][1]

	flavor := sprinkles*ingredients[0][2] +
		peanut*ingredients[1][2] +
		frosting*ingredients[2][2] +
		sugar*ingredients[3][2]

	texture := sprinkles*ingredients[0][3] +
		peanut*ingredients[1][3] +
		frosting*ingredients[2][3] +
		sugar*ingredients[3][3]

	if capacity <= 0 || durability <= 0 || flavor <= 0 || texture <= 0 {
		return 0
	} else {
		return capacity * durability * flavor * texture
	}

}
