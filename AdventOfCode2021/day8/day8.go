package day8

import (
	"sort"
	"strconv"
	"strings"
)

type Line struct {
	signals []string
	answer []string
}

//
// This struct will be used to store the possible corresponding patterns
// A = Top line, B = Left top, ..., I used the same pattern in the AoC problem
//
type Possible struct {
	possible []string
}

func Run(dat []byte) (int, int) {
	
	lines := strings.Split(string(dat), "\n")
	lineArray := make([]Line, len(lines))

	for i, v := range lines {
		splitLine := strings.Split(v, " | ")
		lineArray[i] = Line{signals: strings.Split(splitLine[0], " "),
												answer: strings.Split(splitLine[1], " ")}
	}

	part1 := 0
	for _, value := range lineArray {

		for _, signal := range value.answer {
			if len(signal) == 2 || len(signal) == 3 || len(signal) == 4 || len(signal) == 7 {
				part1++
			}
		}

	}

	part2 := 0
	for _, line := range lineArray {

		currentPossible := make(map[string]Possible)

		//#1 - Get the unique ones.

		//#1.1 - Get the number one
		one := getFromLength(line.signals, 2)[0]
		currentPossible[string(one[0])] = Possible{possible: []string{"C", "F"}}
		currentPossible[string(one[1])] = Possible{possible: []string{"C", "F"}}

		//#1.2 - Get number 7 to work out first link
		seven := getFromLength(line.signals, 3)[0]
		topLink := getOddLetter(seven, one)[0]
		currentPossible[topLink] = Possible{possible: []string{"A"}}

		//#1.3 - Get the number 4.
		four := getFromLength(line.signals, 4)[0]
		oddLetters := getOddLetter(four, one)
		currentPossible[oddLetters[0]] = Possible{possible: []string{"B", "D"}}
		currentPossible[oddLetters[1]] = Possible{possible: []string{"B", "D"}}

		//#1.4 - Get the number 8.
		//The 8 will contain the top link which we already know.
		eight := getFromLength(line.signals, 7)[0]
		oddLetters = getOddLetter(eight, four)

		for _, c := range oddLetters {
			if c != topLink {
				currentPossible[c] = Possible{possible: []string{"E", "G"}}
			}
		}

		//#2 - Get a number with 5 segments on.
		// We want to get a 3, which contains all of the 7s
		// Choose one that thas the top segment.
		fiveLengthNum := getFromLength(line.signals, 5)
		three := ""
		for _, s := range fiveLengthNum {

			contains := true
			for _, c := range seven {
				if !strings.Contains(s, string(c)) {
					contains = false
					break
				}
			}
	
			if contains {
				three = s
				break
			}

		}
		
		//#2.1 Extra segments in 3 but not in 7
		extraLetters := ""
		commonLetters := ""
		for _, c := range three {
			if !strings.Contains(seven, string(c)) {
				extraLetters += string(c)
			} else {
				if string(c) != topLink {
					commonLetters += string(c)
				}
			}
		}

		c1 := currentPossible[string(extraLetters[0])].possible[0]
		c2 := currentPossible[string(extraLetters[0])].possible[1]
		c3 := currentPossible[string(extraLetters[1])].possible[0]
		c4 := currentPossible[string(extraLetters[1])].possible[1]

		//D first then G
		if c1 == "D" && c3 == "G" {
			currentPossible[string(extraLetters[0])] = Possible{possible: []string{"D"}}
			currentPossible[string(extraLetters[1])] = Possible{possible: []string{"G"}}
		} else if c1 == "G" && c3 == "D" {
			currentPossible[string(extraLetters[1])] = Possible{possible: []string{"D"}}
			currentPossible[string(extraLetters[0])] = Possible{possible: []string{"G"}}
		} else if c1 == "D" && c4 == "G" {
			currentPossible[string(extraLetters[0])] = Possible{possible: []string{"D"}}
			currentPossible[string(extraLetters[1])] = Possible{possible: []string{"G"}}
		} else if c1 == "G" && c4 == "D" {
			currentPossible[string(extraLetters[1])] = Possible{possible: []string{"D"}}
			currentPossible[string(extraLetters[0])] = Possible{possible: []string{"G"}}
		} else if c2 == "D" && c3 == "G" {
			currentPossible[string(extraLetters[0])] = Possible{possible: []string{"D"}}
			currentPossible[string(extraLetters[1])] = Possible{possible: []string{"G"}}
		} else if c2 == "G" && c3 == "D" {
			currentPossible[string(extraLetters[1])] = Possible{possible: []string{"D"}}
			currentPossible[string(extraLetters[0])] = Possible{possible: []string{"G"}}
		} else if c2 == "D" && c4 == "G" {
			currentPossible[string(extraLetters[0])] = Possible{possible: []string{"D"}}
			currentPossible[string(extraLetters[1])] = Possible{possible: []string{"G"}}
		} else if c2 == "G" && c4 == "D" {
			currentPossible[string(extraLetters[1])] = Possible{possible: []string{"D"}}
			currentPossible[string(extraLetters[0])] = Possible{possible: []string{"G"}}
		}

		purgeMap(currentPossible)

		//#3 - Now all that is left is to find C & F
		//We can use 6 which contains only contains F
	
		//Get letters of remaining
		remainingNotFound := make([]string, 0)
		for k, v := range currentPossible {
			if len(v.possible) > 1 {
				remainingNotFound = append(remainingNotFound, k)
			}
		}

		sixLengthNum := getFromLength(line.signals, 6)
		remainingNotFoundLetter := ""
		remainingNotFoundLetter2 := ""

		for _, possibleNum := range sixLengthNum {

			reminingNotFoundNum := 0
			for i := 0; i < len(possibleNum); i++ {
				if string(possibleNum[i]) == remainingNotFound[0] {
					reminingNotFoundNum++
					remainingNotFoundLetter = remainingNotFound[0]
					remainingNotFoundLetter2 = remainingNotFound[1]
				} else if string(possibleNum[i]) == remainingNotFound[1] {
					reminingNotFoundNum++
					remainingNotFoundLetter = remainingNotFound[1]
					remainingNotFoundLetter2 = remainingNotFound[0]
				}
			}

			if reminingNotFoundNum == 1 {
				break
			}

		}

		currentPossible[remainingNotFoundLetter] = Possible{possible: []string{"F"}}
		currentPossible[remainingNotFoundLetter2] = Possible{possible: []string{"C"}}

		answer := ""
		for _, testNum := range line.answer {

			testNumArray := make([]string, 0)
			for i := 0; i < len(testNum); i++ {
				testNumArray = append(testNumArray, currentPossible[string(testNum[i])].possible[0])
			}

			answer += getNum(testNumArray)
		}

		numAnswer, _ := strconv.Atoi(answer)
		part2 += numAnswer

	}

	return part1, part2

}

func purgeMap(givenMap map[string]Possible) {

	singleValues := make([]string, 0)
	for _, v := range givenMap {
		if len(v.possible) == 1 {
			singleValues = append(singleValues, v.possible[0])
		}
	}
	
	for k, v := range givenMap {
		
		//Check that any of the single values are in v
		newValues := make([]string, 0)
		for _, singleValue := range v.possible {
			if !containsInArray(singleValues, singleValue) {
				newValues = append(newValues, singleValue)
			}
		}

		if len(newValues) > 0 {
			givenMap[k] = Possible{possible: newValues}
		}

	}

}

func getNum(arr []string) string {

	sort.Strings(arr)
	if equals(arr, []string{"A", "B", "C", "E", "F", "G"}) {
		return "0"	
	} else if equals(arr, []string{"C", "F"}) {
		return "1"
	} else if equals(arr, []string{"A", "C", "D", "E", "G"}) {
		return "2"
	} else if equals(arr, []string{"A", "C", "D", "F", "G"}) {
		return "3"
	} else if equals(arr, []string{"B", "D", "C", "F"}) {
		return "4"
	} else if equals(arr, []string{"A", "B", "D", "F", "G"}) {
		return "5"
	} else if equals(arr, []string{"A", "B", "D", "E", "F", "G"}) {
		return "6"
	} else if equals(arr, []string{"A", "C", "F"}) {
		return "7"
	} else if equals(arr, []string{"A", "B", "C", "D", "E", "F", "G"}) {
		return "8"
	} else if equals(arr, []string{"A", "B", "C", "D", "F", "G"}) {
		return "9"
	}

	return ""

}

func getFromLength(arr []string, length int) []string {
	returnArray := make([]string, 0)
	for _, v := range arr {
		if len(v) == length {
			returnArray = append(returnArray, v)
		}
	}
	return returnArray
}

//First parameter is the bigger array
func getOddLetter(string1 string, string2 string) []string {

	returnArray := make([]string, 0)
	for _, v := range string1 {
		if !contains(string2, v) {
			returnArray = append(returnArray, string(v))
		}
	}
	return returnArray

}

func contains(givenString string, value rune) bool {
	for _, v := range givenString {
		if v == value {
			return true
		}
	}
	return false
}

func containsInArray(givenArr []string, char string) bool {
	for _, v := range givenArr {
		if v == char {
			return true
		}
	}
	return false
}

func equals(arr1 []string, arr2 []string) bool {

	sort.Strings(arr1)
	sort.Strings(arr2)

	for i, v := range arr1 {
		if v != arr2[i] {
			return false
		}
	}
	return true
}