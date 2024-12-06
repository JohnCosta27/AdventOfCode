package main

import (
	"fmt"
	"os"
	"regexp"
	"strings"
)

func GetRule(rules *map[string]string, r string) string {
	rule := (*rules)[r]

	if strings.Contains(rule, `"`) {
		// Base case
		matchLetter := rule[1 : len(rule)-1]
		return matchLetter
	}

	alternates := strings.Split(rule, " | ")

	if len(alternates) == 1 {
		ruleNumbers := strings.Split(alternates[0], " ")
		str := ""
		for _, n := range ruleNumbers {
			str += GetRule(rules, n)
		}
		return str
	}

	if len(alternates) > 1 {
		ruleNumbers := strings.Split(alternates[0], " ")
		firstAlternate := ""
		for _, n := range ruleNumbers {
			firstAlternate += GetRule(rules, n)
		}

		ruleNumbers = strings.Split(alternates[1], " ")
		secondAlternate := ""
		for _, n := range ruleNumbers {
			secondAlternate += GetRule(rules, n)
		}

		return fmt.Sprintf("(%s|%s)", firstAlternate, secondAlternate)
	}

	panic("should never be here")
}

func main() {

	content, err := os.ReadFile("./input.txt")
	if err != nil {
		panic(err)
	}

	splitInput := strings.Split(string(content), "\n\n")
	rules := strings.Split(splitInput[0], "\n")

	ruleMap := make(map[string]string)

	for _, rule := range rules {
		splitRule := strings.Split(rule, ": ")
		ruleNumber := splitRule[0]

		ruleMap[ruleNumber] = splitRule[1]
	}

	tests := splitInput[1]
	tests = tests[0 : len(tests)-1]

	zeroRule := regexp.MustCompile("^" + GetRule(&ruleMap, "0") + "$")

	matches := 0
	for _, t := range strings.Split(tests, "\n") {
		if zeroRule.Match([]byte(t)) {
			matches++
		}
	}

	fmt.Printf("Part 1: %d\n", matches)

	fRule := regexp.MustCompile(GetRule(&ruleMap, "42"))
	tRule := regexp.MustCompile(GetRule(&ruleMap, "31"))

	matches = 0
	for _, t := range strings.Split(tests, "\n") {

		// rule 0 = 8 11
		// 8 = 42+
		// 11 = 42{n} 31{n}
		// Therefore: 0 = 42 {n*2} 31{n}

		fortyTwoMatch := fRule.FindStringIndex(t)
		fortyTwoCount := 0
		for fortyTwoMatch != nil && fortyTwoMatch[0] == 0 {
			t = t[fortyTwoMatch[1]:]
			fortyTwoMatch = fRule.FindStringIndex(t)
			fortyTwoCount++
		}

		thirtyMatch := tRule.FindStringIndex(t)
		thirtyCount := 0
		for thirtyMatch != nil && thirtyMatch[0] == 0 {
			t = t[thirtyMatch[1]:]
			thirtyMatch = tRule.FindStringIndex(t)
			thirtyCount++
		}

		if len(t) == 0 && thirtyCount > 0 && fortyTwoCount > thirtyCount {
			matches++
		}
	}

	fmt.Printf("Part 2: %d\n", matches)
}
