package day2

import (
	"bytes"
	"strconv"
)

func Run(dat []byte) (int, int) {
  
  dat = dat[:len(dat) - 1]
    
  lines := bytes.Split(dat, []byte("\n"))

  vertical := 0
  horizontal := 0

  part2vertical := 0
  part2horizontal := 0
  aim := 0

  for _, value := range lines {
    
    splitInstruction := bytes.Split(value, []byte(" "))

    direction := string(splitInstruction[0])
    scale, _ := strconv.Atoi(string(splitInstruction[1]))
    
    if direction == "forward" {
      horizontal += scale
      part2horizontal += scale
      part2vertical += aim * scale
    } else if direction == "up" {
      vertical -= scale
      aim -= scale
    } else if direction == "down" {
      vertical += scale
      aim += scale
    }

  }

  return vertical * horizontal, part2vertical * part2horizontal

}
