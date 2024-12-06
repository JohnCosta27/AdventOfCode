package day4

import (
	"strconv"
	"strings"
)

func Run(dat []byte) (int, int) {

  stringData := string(dat)

  lines := strings.Split(stringData, "\n")

  numbersDrawn := strings.Split(lines[0], ",")
  lines = lines[2:]

  currentBoard := make([][]int, 0)
  boards := make([][][]int, 0)

  for _, line := range lines {

    if len(line) == 0 {
      boards = append(boards, currentBoard)
      currentBoard = make([][]int, 0)
    } else {
      currentLine := strings.Split(line, " ")
      intLine := make([]int, 5)

      counter := 0

      for i := 0; i < len(currentLine); i++ {
        if (len(currentLine[i]) > 0) {
          intLine[counter], _ = strconv.Atoi(currentLine[i])
          counter++
        }
      }
      currentBoard = append(currentBoard, intLine)
    }

  }

  /**
    * There is probably a better way of doing this
    */
  boardCheck := make([][][]int, 0)
  for i := 0; i < len(boards); i++ {
    boardCheck = append(boardCheck, [][]int{{0, 0, 0, 0, 0}, 
      {0, 0, 0, 0, 0}, 
      {0, 0, 0, 0, 0}, 
      {0, 0, 0, 0, 0},
      {0, 0, 0, 0, 0}})
  }

  boardComplete := false
  winningIndex := 0
  calledNumber := 0

  //Part 1
  for i := 0; i < len(numbersDrawn) && !boardComplete; i++ {

    intNumber, _ := strconv.Atoi(numbersDrawn[i])

    for i, board := range boards {
      checkBoard(board, intNumber, &boardCheck[i])
      if checkComplete(boardCheck[i]) {
        boardComplete = true
        winningIndex = i
        calledNumber = intNumber
        break
      }
    }

  }

  boardCheck = make([][][]int, 0)
  for i := 0; i < len(boards); i++ {
    boardCheck = append(boardCheck, [][]int{{0, 0, 0, 0, 0}, 
      {0, 0, 0, 0, 0}, 
      {0, 0, 0, 0, 0}, 
      {0, 0, 0, 0, 0},
      {0, 0, 0, 0, 0}})
  }

  completedBoards := make([]int, 0)
  lastFound := -1
  part2Num := 0

  for i := 0; i < len(numbersDrawn) && lastFound == -1; i++ {

    intNumber, _ := strconv.Atoi(numbersDrawn[i])
    for i, board := range boards {

      if !contains(completedBoards, i) {
        checkBoard(board, intNumber, &boardCheck[i])
       
        if checkComplete(boardCheck[i]) {
          completedBoards = append(completedBoards, i)

          if len(completedBoards) == len(boards) {
            part2Num = intNumber
            lastFound = i
            break
          }

        }
      }

    }

  }

  unmarkedNumbers := 0
  partUnmarkedNumbers := 0

  for i := 0; i < len(boards[winningIndex]); i++ {
    for j := 0; j < len(boards[winningIndex][0]); j++ {

      if boardCheck[winningIndex][i][j] == 0 {
        unmarkedNumbers += boards[winningIndex][i][j]
      }

    }
  }

  for i := 0; i < len(boards[lastFound]); i++ {
    for j := 0; j < len(boards[lastFound][0]); j++ {

      if boardCheck[lastFound][i][j] == 0 {
        partUnmarkedNumbers += boards[lastFound][i][j]
      }

    }
  }

  return calledNumber * unmarkedNumbers, part2Num * partUnmarkedNumbers

}

func contains(arr []int, num int) bool {
  for _, e := range arr {
    if e == num {
      return true
    }
  }
  return false
}

func checkBoard(board [][]int, numberDrawn int, boardCheck *[][]int) {

  for i := 0; i < len(board); i++ {
    for j := 0; j < len(board[0]); j++ {

      if board[i][j] == numberDrawn {
        (*boardCheck)[i][j] = 1
      }

    }
  }
  
}

//Return -1 if board is not complete
func checkComplete(boardCheck [][]int) bool {

  //Check rows
  for i := 0; i < len(boardCheck); i++ {
    
    rowComplete := true
    for j := 0; j < len(boardCheck[0]); j++ {
      if boardCheck[i][j] == 0 {
        rowComplete = false
      }
    }

    if rowComplete {
      return true
    }

  }

  //Check cols
  for i := 0; i < len(boardCheck); i++ {
    
    colComplete := true
    for j := 0; j < len(boardCheck[0]); j++ {
      if boardCheck[j][i] == 0 {
        colComplete = false
      }
    }

    if colComplete {
      return true
    }

  }

  return false

}