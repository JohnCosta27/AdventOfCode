package day3

import (
	"bytes"
)

func Run(dat []byte) (int, int) {
  
  lines := bytes.Split(dat, []byte("\n"))
  lineLength := len(lines[0])

  commonMap := make(map[int]int)

  for _, line := range lines {

    splitLine := bytes.Split(line, []byte(""))
    
    for i := 0; i < len(splitLine); i++ {

      //Negative means that 0 is more common
      if splitLine[i][0] == 0x31 {
        commonMap[i] = commonMap[i] - 1
      } else {
        commonMap[i] = commonMap[i] + 1 
      }

    }
    
  }

  gamma := 0
  epsilon := 0

  for key, value := range commonMap {
    if value > 0 {
      gamma += intExponent(2, lineLength - key - 1)
    } else {
      epsilon += intExponent(2, lineLength - key - 1)
    }
  }

  return gamma * epsilon, part2(lines[:len(lines) - 1], true, 0) * 
                          part2(lines[:len(lines) - 1], false, 0)

}

func part2(givenLines [][]byte, higher bool, checkPosition int) int {

  if len(givenLines) == 1 {
    returnValue := 0
    
    for i := len(givenLines[0]) - 1; i >= 0; i-- {

      if givenLines[0][len(givenLines[0]) - 1 - i] == 0x31 {
        returnValue += intExponent(2, i)
      }

    }
    return returnValue
  } else {
    
    oneLines := make([][]byte, 0)
    zeroLines := make([][]byte, 0)

    for _, line := range givenLines {
      if line[checkPosition] == 0x31 {
        oneLines = append(oneLines, line)
      } else {
        zeroLines = append(zeroLines, line)
      }
    }
    
    if higher {

      if len(oneLines) >= len(zeroLines) {
        return part2(oneLines, higher, checkPosition + 1)
      } else if len(oneLines) < len(zeroLines) {
        return part2(zeroLines, higher, checkPosition + 1)
      }

    } else {
      
      if len(oneLines) >= len(zeroLines) {
        return part2(zeroLines, higher, checkPosition + 1)
      } else if len(oneLines) < len(zeroLines) {
        return part2(oneLines, higher, checkPosition + 1)
      }

    }

  }
  return 0
}

func intExponent(base int, power int) int {
  result := 1
  for i := 1; i <= power; i++ {
    result *= base
  }
  return result
}
