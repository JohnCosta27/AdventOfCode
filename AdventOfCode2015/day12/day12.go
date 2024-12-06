package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"time"
)

func main() {
	fmt.Println("Day 12")
	start := time.Now()

	dat, err := ioutil.ReadFile("day12.json")
	if err != nil {
		panic(err)
	}

	var result map[string]interface{}
	json.Unmarshal(dat, &result)
	fmt.Printf("Input: %v | %T \n", result, result)

	var count float64 = solver(result)

	elapsed := time.Since(start)
	fmt.Printf("Part 1: %v %v \n", count, elapsed)

}

func solver(json map[string]interface{}) float64 {
	var counter float64
	for _, value := range json {
		switch valueType := value.(type) {
		case bool:
		case float64:
			counter += valueType
		case string:
		case []interface{}:
			counter += interfaceArraySolver(valueType)
		case map[string]interface{}:
			counter += solver(valueType)
		}

	}
	return counter
}

func interfaceArraySolver(json []interface{}) float64 {
	var counter float64
	for _, value := range json {
		switch valueType := value.(type) {
		case bool:
		case float64:
			counter += valueType
		case string:
		case []interface{}:
			counter += interfaceArraySolver(valueType)
		case map[string]interface{}:
			counter += solver(valueType)
		}

	}
	return counter
}
