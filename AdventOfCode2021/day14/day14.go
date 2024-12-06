package day14

import (
	"strings"
)

func Run(dat []byte) (int64, int64) {
  
  lines := strings.Split(string(dat), "\n")
  template := lines[0]
  patterns := lines[2 : len(lines) - 1]

  pairInsertions := make(map[string]string, len(patterns))
  for i := 0; i < len(patterns); i++ {
    pairSplit := strings.Split(patterns[i], " ")
    pairInsertions[pairSplit[0]] = pairSplit[2]
  }

  for round := 0; round < 40; round++ {
    
    newTemplate := string(template[0])
    for i := 0; i < len(template) - 1; i++ {
      pair := template[i:i + 2]
      newLetter := pairInsertions[pair]
      newTemplate += newLetter + string(pair[1])
    } 
    template = newTemplate

  }

  letterMap := make(map[byte]int64, 0)
  for i := 0; i < len(template); i++ {
    letterMap[template[i]] += 1
  }

  highest := int64(0)
  lowest := int64(999999)
  for _, v := range letterMap {
    if v > highest {
      highest = v
    } else if v < lowest {
      lowest = v
    }
  }

  return (highest - lowest), 0
}
