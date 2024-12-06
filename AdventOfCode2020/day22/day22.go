package main

import (
	"fmt"
	"os"
	"slices"
	"strconv"
	"strings"
)

type Queue struct {
  arr []int
  head uint
  tail uint
}

func (s *Queue) Dequeue() int {
  s.head++
  return s.arr[s.head - 1]
}

func (s *Queue) Enqueue(num int) {
  if len(s.arr) <= int(s.tail) {
    s.arr = append(s.arr, num)
  } else {
    s.arr[s.tail] = num
  }
  s.tail++
}

func (s *Queue) Print() string {
  str := ""
  for i := s.head; i < s.tail; i++ {
    str += strconv.Itoa(s.arr[i]) + ","
  }
  return str
}

func main() {
  content, err := os.ReadFile("./input.txt")
  if err != nil {
    panic(err)
  }

  players := strings.Split(string(content), "\n\n")

  player1 :=  strings.Split(players[0], "\n")[1:]
  player2 := strings.Split(players[1], "\n")[1:]

  player1Cards := Queue{
    arr: make([]int, 0),
    head: 0,
    tail: 0,
  }
  player2Cards := Queue{
    arr: make([]int, 0),
    head: 0,
    tail: 0,
  }

  for _, v := range player1 {
    n, err := strconv.Atoi(v)
    if err != nil {
      panic(err)
    }
    player1Cards.Enqueue(n)
  }

  for _, v := range player2 {
    if len(v) == 0 {
      continue
    }
    n, err := strconv.Atoi(v)
    if err != nil {
      panic(err)
    }
    player2Cards.Enqueue(n)
  }

  /*
  rounds := 0
  for {
    if player1Cards.head == player1Cards.tail  || player2Cards.head == player2Cards.tail {
      break
    }

    player1Card := player1Cards.Dequeue()
    player2Card := player2Cards.Dequeue()
    if player1Card > player2Card {
      player1Cards.Enqueue(player1Card)
      player1Cards.Enqueue(player2Card)
    } else {
      player2Cards.Enqueue(player2Card)
      player2Cards.Enqueue(player1Card)
    }

    rounds++
  }

  */

  _, p1, p2 := PlayGame(player1Cards, player2Cards)

  var winningScore uint = 0
  if p1.tail - p1.head < p2.tail - p2.head {
    for i := p2.head; i < p2.tail; i++ {
      winningScore += (p2.tail - i) * uint(p2.arr[i])
    }
  } else {
    for i := p1.head; i < p1.tail; i++ {
      winningScore += (p1.tail - i) * uint(p1.arr[i])
    }
  }

  fmt.Println(winningScore)
}

// true = player1, false = player2
func PlayGame(player1 Queue, player2 Queue) (bool, *Queue, *Queue) {
  cache1 := make(map[string]bool)
  cache2 := make(map[string]bool)
  for {
    if player1.head == player1.tail  || player2.head == player2.tail {
      return player2.head == player2.tail, &player1, &player2
    }

    // Before drawing, check.
    player1string := player1.Print()
    player2string := player2.Print()

    _, exists := cache1[player1string]
    if exists {
      return true, &player1, &player2
    }

    _, exists = cache2[player2string]
    if exists {
      return true, &player1, &player2
    }

    cache1[player1string] = true
    cache2[player2string] = true


    player1Card := player1.Dequeue()
    player2Card := player2.Dequeue()
    
    if int(player1.tail) - int(player1.head) >= player1Card && int(player2.tail) - int(player2.head) >= player2Card {
      // Recursive case!
      player1Copy := Queue{
        arr: slices.Clone(player1.arr),
        head: player1.head,
        tail: player1.head + uint(player1Card),
      }

      player2Copy := Queue{
        arr: slices.Clone(player2.arr),
        head: player2.head,
        tail: player2.head + uint(player2Card),
      }

      winner, _, _ := PlayGame(player1Copy, player2Copy)
      if winner {
        player1.Enqueue(player1Card)
        player1.Enqueue(player2Card)
      } else {
        player2.Enqueue(player2Card)
        player2.Enqueue(player1Card)
      }
    } else {
      if player1Card > player2Card {
        player1.Enqueue(player1Card)
        player1.Enqueue(player2Card)
      } else {
        player2.Enqueue(player2Card)
        player2.Enqueue(player1Card)
      }
    }
  }

}

func GetString(arr []int) string {
  s := ""
  for _, v := range arr {
    s += "," + strconv.Itoa(v)
  }
  return s
}
