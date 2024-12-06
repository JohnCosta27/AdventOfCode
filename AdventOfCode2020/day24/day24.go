package main

import (
	"fmt"
	"os"
	"regexp"
	"strconv"
	"strings"
)

type Hex struct {
  q int
  r int
  s int
}

func CreateHex(q int, r int, s int) Hex {
  return Hex{
    q: q,
    r: r,
    s: s,
  }
}

func (h *Hex) Print() string {
  return strconv.Itoa(h.q) + "," + strconv.Itoa(h.r) + "," + strconv.Itoa(h.s)
}

func Count(arr []string, search string) int {
  counter := 0
  for i := 0; i < len(arr); i++ {
    if arr[i] == search {
      counter++
    }
  }
  return counter
}

func AdjustValues(hexMap map[string]bool, key string, white *int, black *int) {
  v, exists := hexMap[key]
  if !exists {
    return
  }

  if v {
    *white++
  } else {
    *black++
  }
}

func AddIfMissing(hexMap map[string]bool, hex string) {
  _, exists := hexMap[hex]
  if !exists {
    hexMap[hex] = true
  }
}

func AddAdjacents(hexMap map[string]bool, hex string) {
  split := strings.Split(hex, ",")
  q, _ := strconv.Atoi(split[0])
  r, _ := strconv.Atoi(split[1])
  s, _ := strconv.Atoi(split[2])

  nw := strconv.Itoa(q) + "," + strconv.Itoa(r - 1) + "," + strconv.Itoa(s + 1)
  w := strconv.Itoa(q - 1) + "," + strconv.Itoa(r) + "," + strconv.Itoa(s + 1)
  sw := strconv.Itoa(q - 1) + "," + strconv.Itoa(r + 1) + "," + strconv.Itoa(s)
  se := strconv.Itoa(q) + "," + strconv.Itoa(r + 1) + "," + strconv.Itoa(s - 1)
  e := strconv.Itoa(q + 1) + "," + strconv.Itoa(r) + "," + strconv.Itoa(s - 1)
  ne := strconv.Itoa(q + 1) + "," + strconv.Itoa(r - 1) + "," + strconv.Itoa(s)

  AddIfMissing(hexMap, nw)
  AddIfMissing(hexMap, w)
  AddIfMissing(hexMap, sw)
  AddIfMissing(hexMap, se)
  AddIfMissing(hexMap, e)
  AddIfMissing(hexMap, ne)
}

func CountAdjacent(hexMap map[string]bool, hex string) (int, int) {
  white := 0
  black := 0

  split := strings.Split(hex, ",")
  q, _ := strconv.Atoi(split[0])
  r, _ := strconv.Atoi(split[1])
  s, _ := strconv.Atoi(split[2])

  nw := strconv.Itoa(q) + "," + strconv.Itoa(r - 1) + "," + strconv.Itoa(s + 1)
  w := strconv.Itoa(q - 1) + "," + strconv.Itoa(r) + "," + strconv.Itoa(s + 1)
  sw := strconv.Itoa(q - 1) + "," + strconv.Itoa(r + 1) + "," + strconv.Itoa(s)
  se := strconv.Itoa(q) + "," + strconv.Itoa(r + 1) + "," + strconv.Itoa(s - 1)
  e := strconv.Itoa(q + 1) + "," + strconv.Itoa(r) + "," + strconv.Itoa(s - 1)
  ne := strconv.Itoa(q + 1) + "," + strconv.Itoa(r - 1) + "," + strconv.Itoa(s)

  AdjustValues(hexMap, nw, &white, &black)
  AdjustValues(hexMap, w, &white, &black)
  AdjustValues(hexMap, sw, &white, &black)
  AdjustValues(hexMap, se, &white, &black)
  AdjustValues(hexMap, e, &white, &black)
  AdjustValues(hexMap, ne, &white, &black)

  return white, black
}

func main() {
  fmt.Println("Day 24 Part 1")

  file, err := os.ReadFile("input.txt")
  if err != nil {
    panic(err)
  }
  _content := strings.Split(string(file), "\n")
  content := _content[:len(_content) - 1]

  directionRegex := regexp.MustCompile("e|se|sw|w|nw|ne")

  // true = white, false = black
  cache := make(map[string]bool)

  for _, line := range content {
    matches := directionRegex.FindAllString(line, -1)
    
    nw := Count(matches, "nw")
    w := Count(matches, "w")
    sw := Count(matches, "sw")
    se := Count(matches, "se")
    e := Count(matches, "e")
    ne := Count(matches, "ne")

    hex := CreateHex(ne + e - sw - w, se + sw - ne - nw, w + nw - se - e)

    white, exists := cache[hex.Print()]
    if !exists {
      cache[hex.Print()] = false
    } else {
      cache[hex.Print()] = !white
    }
  }

  blackTiles := 0
  for _, white := range cache {
    if !white {
      blackTiles++
    }
  }

  fmt.Printf("Part 1: %d\n", blackTiles)

  for i := 0; i < 100; i++ {
    
    toFlip := make([]string, 0)
    for k := range cache {
      AddAdjacents(cache, k)
    }

    for k, isWhite := range cache {
      _, black := CountAdjacent(cache, k)
      if isWhite && black == 2 {
        toFlip = append(toFlip, k) 
      } else if !isWhite && (black == 0 || black > 2) {
        toFlip = append(toFlip, k) 
      }
    }

    for _, k := range toFlip {
      cache[k] = !cache[k]
    }

    myTiles := 0
    for _, white := range cache {
      if !white {
        myTiles++
      }
    }
    fmt.Println(i, myTiles)
  }
}
