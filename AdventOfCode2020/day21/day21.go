package main

import (
	"fmt"
	"os"
	"slices"
	"strings"
)

func contains(arr []string, search string) bool {
  for _, val := range arr {
    if val == search {
      return true
    }
  }
  return false
}

func remove(arr []string, item string) []string {
  newThing := make([]string, 0)
  for _, val := range arr {
    if val != item {
      newThing = append(newThing, val)
    }
  }
  return newThing
}

func mergeSets(set1 []string, set2 []string) []string {
  merged := make([]string, 0)
  for _, val := range set1 {
    if (contains(set2, val)) {
      merged = append(merged, val)
    }
  }

  return merged
}

func isMapSingleValue(myMap map[string][]string) bool {
  for _, v := range myMap {
    if len(v) > 1 {
      return false
    }
  }
  return true
}

func main() {
  content, err := os.ReadFile("./input.txt")
  if err != nil {
    panic(err)
  }

  _lines := strings.Split(string(content), "\n")
  lines := _lines[:len(_lines) - 1]

  myMap := make(map[string][]string)

  totalIngredients := make([]string, 0)

  for _, line := range lines {
    split := strings.Split(line, " (contains ")
    if (len(split) == 0) {
      continue
    }

    ingredients := strings.Split(split[0], " ")
    for _, i := range ingredients {
      totalIngredients = append(totalIngredients, i)
    }

    formatted := strings.Split(strings.TrimSuffix(split[1], ")"), ", ")
    for _, v := range formatted {
      val, exists := myMap[v]
      if !exists {
        myMap[v] = ingredients
        continue
      }

      newSets := mergeSets(val, ingredients)
      myMap[v] = newSets

      if (len(newSets) == 1) {
        found := newSets[0]
        for key, mapVal := range myMap {
          if key == v {
            continue
          }
          if (contains(mapVal, found)) {
            myMap[key] = remove(mapVal, found)
          }
        }
      }
    }
  }

  for !isMapSingleValue(myMap) {
    for firstK, v := range myMap {
      if len(v) == 1 {
        for k, i := range myMap {
          if k == firstK {
            continue
          }
          myMap[k] = remove(i, v[0])
        }
      }
    }
  }

  allMapValues := make([]string, 0)
  for _, v := range myMap {
    for _, j := range v {
      if (!contains(allMapValues, j)) {
        allMapValues = append(allMapValues, j)
      }
    }
  }

  fmt.Printf("%+v\n", myMap)

  for _, v := range allMapValues {
    totalIngredients = remove(totalIngredients, v)
  }

  myIngredientList := make([]string, 0)
  for k := range myMap {
    myIngredientList = append(myIngredientList, k)
  }
  slices.Sort(myIngredientList)

  part2 := ""
  for _, v := range myIngredientList {
    part2 += myMap[v][0] + ","
  }
  part2 = strings.TrimSuffix(part2, ",")

  fmt.Println(len(totalIngredients))
  fmt.Println(part2)
}
