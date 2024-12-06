package day1

import (
	"bytes"
	"strconv"
)

func Run(dat []byte) (int, int) {

  lines := bytes.Split(dat, []byte("\n"))

  increase := 0
  increaseWindow := 0

  for i := 0; i < len(lines) - 1; i++ {
    
    num1, _ := strconv.Atoi(string(lines[i]))
    num2, _ := strconv.Atoi(string(lines[i + 1]))

    if num1 < num2 {
      increase++
    }

  }

  for i := 0; i < len(lines) - 3; i++ {
    
    num1, _ := strconv.Atoi(string(lines[i]))
    num2, _ := strconv.Atoi(string(lines[i + 1]))
    num3, _ := strconv.Atoi(string(lines[i + 2]))
    num4, _ := strconv.Atoi(string(lines[i + 3]))

    if num1 + num2 + num3 < num2 + num3 + num4 {
      increaseWindow++
    }

  }

  return increase, increaseWindow

}
