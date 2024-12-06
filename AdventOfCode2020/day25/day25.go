package main

import "fmt"

func main() {
  var dividerr int64 = 20201227
  // var cardPKey int64 = 5764801
  // var doorPKey int64 = 17807724

  var cardPKey int64 = 16915772
  var doorPKey int64 = 18447943

  var cardValue int64 = 1
  var cardLoopSize int64 = 0

  for cardValue != cardPKey {
    cardValue *= 7 // Subject number
    cardValue = cardValue % dividerr
    cardLoopSize++
  }

  var doorValue int64 = 1
  var doorLoopSize int64 = 0

  for doorValue != doorPKey {
    doorValue *= 7 // Subject number
    doorValue = doorValue % dividerr
    doorLoopSize++
  }

  var part1 int64 = 1
  var i int64 = 0
  
  for i = 0; i < cardLoopSize; i++ {
    part1 *= doorPKey
    part1 = part1 % dividerr
  }

  fmt.Printf("Part 1: %d %d %d\n", cardLoopSize, doorLoopSize, part1)
}
