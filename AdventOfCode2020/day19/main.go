package main

import (
	"fmt"
	"os"
	"strings"
)

var THREE_SIMPLE_RULE = `
func Rule%s(message string, index *int) error {
  err := Rule%s(message, index)
  if err != nil {
    return err
  }

  err = Rule%s(message, index)
  if err != nil {
    return err
  }

  err = Rule%s(message, index)
  if err != nil {
    return err
  }

  return nil
}
`

var SIMPLE_RULE = `
func Rule%s(message string, index *int) error {
  err := Rule%s(message, index)
  if err != nil {
    return err
  }

  err = Rule%s(message, index)
  if err != nil {
    return err
  }

  return nil
}
`

var ONE_SIMPLE_RULE = `
func Rule%s(message string, index *int) error {
  err := Rule%s(message, index)
  if err != nil {
    return err
  }

  return nil
}
`

var ALTERNATE_RULE = `
func Rule%s(message string, index *int) error {
  indexCopy := *index
  err := Rule%sFirst(message, &indexCopy)

  if err == nil {
    *index = indexCopy
    return nil
  }

  err = Rule%sSecond(message, index)
  return err
}
%s
%s
`

var LITERAL_RULE = `
func Rule%s(message string, index *int) error {
  if len(message) <= *index {
    return errors.New("out of bounds")
  }

  if string(message[*index]) == "%c" {
    *index++
    return nil
  }
  return errors.New("Could not match")
}
`

func main() {
  content, err := os.ReadFile("./input.txt")
  if err != nil {
    panic(err)
  }

  splitInput := strings.Split(string(content), "\n\n")

  program := `
  package main

  import (
    "errors"
    "fmt"
    "os"
    "strings"
  )

  func main() {
    content, err := os.ReadFile("./input.txt")
    if err != nil {
      panic(err)
    }

    splitInput := strings.Split(string(content), "\n\n")
    toTry := splitInput[1]
    counter := 0

    toTrySplit := strings.Split(toTry, "\n")
    
    for _, v := range toTrySplit[0: len(toTrySplit) - 1] {
      index := 0
      err := Rule0(v, &index)
      if err == nil && index == len(v) {
        counter++
      }
    }

    fmt.Println(counter)
  }
  `

  rules := strings.Split(splitInput[0], "\n")
  for _, v := range rules {
    
    /*
    if v == "8: 42" {
      v = "8: 42 | 42 8"
    } else if v == "11: 42 31" {
      v = "11: 42 31 | 42 11 31"
    }
    */

    program += CreateRule(v)
  }

  err = os.WriteFile("./parser.go", []byte(program), 0777)
  if err != nil {
    panic(err)
  }
}

func CreateRule(rule string) (string) {
  splitRule := strings.Split(rule, ": ")
  ruleNumber := splitRule[0]

  rules := strings.Split(splitRule[1], " | ")

  if (len(rules) == 1) {
    return CreateSingleRule(ruleNumber, rules[0])
  }

  return fmt.Sprintf(ALTERNATE_RULE, ruleNumber, ruleNumber, ruleNumber, CreateSingleRule(ruleNumber + "First", rules[0]), CreateSingleRule(ruleNumber + "Second", rules[1]))
}

// Single rule (4 5) or ("a")
func CreateSingleRule(ruleNumber string, rule string) string {
  if string(rule[0]) == string('"') {
    return fmt.Sprintf(LITERAL_RULE, ruleNumber, rule[1])
  }

  nums := strings.Split(rule, " ")

  if len(nums) == 3 {
    return fmt.Sprintf(THREE_SIMPLE_RULE, ruleNumber, nums[0], nums[1], nums[2])
  } else if (len(nums) == 2) {
    return fmt.Sprintf(SIMPLE_RULE, ruleNumber, nums[0], nums[1])
  }

  return fmt.Sprintf(ONE_SIMPLE_RULE, ruleNumber, nums[0])
}


/*
func Rule0(message string, index *int) error {
  err := Rule1(message, index)
  if err != nil {
    return err
  }

  err := Rule2(message, index)
  if err != nil {
    return err
  }

  return nil
}

func Rule2(message string, index *int) error {
  indexCopy := *index
  err := Rule2First(message, &indexCopy)

  if err == nil {
    return nil
  }

  err = Rule2Second(message, index)
  return err
}

func Rule2First(message string, index *int) error {
  err := Rule1(message, index)
  if err != nil {
    return err
  }

  err := Rule3(message, index)
  if err != nil {
    return err
  }

  return nil
}

func Rule2Second(message string, index *int) error {
  err := Rule3(message, index)
  if err != nil {
    return err
  }

  err := Rule1(message, index)
  if err != nil {
    return err
  }

  return nil
}

func Rule3(message string, index *int) errro {
  if message[*index] == "b" {
    	x := 5
	y := &x
	*y = *y + 1
	fmt.Println(x)
  }
}


func Rule3(message string, index *int) error {
  if string(message[*index]) == "b" {
    *index++
    return nil
  }
  return errors.New("Could not match")
}
*/
