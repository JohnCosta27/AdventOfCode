
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
  
func Rule42(message string, index *int) error {
  indexCopy := *index
  err := Rule42First(message, &indexCopy)

  if err == nil {
    *index = indexCopy
    return nil
  }

  err = Rule42Second(message, index)
  return err
}

func Rule42First(message string, index *int) error {
  err := Rule9(message, index)
  if err != nil {
    return err
  }

  err = Rule14(message, index)
  if err != nil {
    return err
  }

  return nil
}


func Rule42Second(message string, index *int) error {
  err := Rule10(message, index)
  if err != nil {
    return err
  }

  err = Rule1(message, index)
  if err != nil {
    return err
  }

  return nil
}


func Rule9(message string, index *int) error {
  indexCopy := *index
  err := Rule9First(message, &indexCopy)

  if err == nil {
    *index = indexCopy
    return nil
  }

  err = Rule9Second(message, index)
  return err
}

func Rule9First(message string, index *int) error {
  err := Rule14(message, index)
  if err != nil {
    return err
  }

  err = Rule27(message, index)
  if err != nil {
    return err
  }

  return nil
}


func Rule9Second(message string, index *int) error {
  err := Rule1(message, index)
  if err != nil {
    return err
  }

  err = Rule26(message, index)
  if err != nil {
    return err
  }

  return nil
}


func Rule10(message string, index *int) error {
  indexCopy := *index
  err := Rule10First(message, &indexCopy)

  if err == nil {
    *index = indexCopy
    return nil
  }

  err = Rule10Second(message, index)
  return err
}

func Rule10First(message string, index *int) error {
  err := Rule23(message, index)
  if err != nil {
    return err
  }

  err = Rule14(message, index)
  if err != nil {
    return err
  }

  return nil
}


func Rule10Second(message string, index *int) error {
  err := Rule28(message, index)
  if err != nil {
    return err
  }

  err = Rule1(message, index)
  if err != nil {
    return err
  }

  return nil
}


func Rule1(message string, index *int) error {
  if len(message) <= *index {
    return errors.New("out of bounds")
  }

  if string(message[*index]) == "a" {
    *index++
    return nil
  }
  return errors.New("Could not match")
}

func Rule11(message string, index *int) error {
  err := Rule42(message, index)
  if err != nil {
    return err
  }

  err = Rule31(message, index)
  if err != nil {
    return err
  }

  return nil
}

func Rule5(message string, index *int) error {
  indexCopy := *index
  err := Rule5First(message, &indexCopy)

  if err == nil {
    *index = indexCopy
    return nil
  }

  err = Rule5Second(message, index)
  return err
}

func Rule5First(message string, index *int) error {
  err := Rule1(message, index)
  if err != nil {
    return err
  }

  err = Rule14(message, index)
  if err != nil {
    return err
  }

  return nil
}


func Rule5Second(message string, index *int) error {
  err := Rule15(message, index)
  if err != nil {
    return err
  }

  err = Rule1(message, index)
  if err != nil {
    return err
  }

  return nil
}


func Rule19(message string, index *int) error {
  indexCopy := *index
  err := Rule19First(message, &indexCopy)

  if err == nil {
    *index = indexCopy
    return nil
  }

  err = Rule19Second(message, index)
  return err
}

func Rule19First(message string, index *int) error {
  err := Rule14(message, index)
  if err != nil {
    return err
  }

  err = Rule1(message, index)
  if err != nil {
    return err
  }

  return nil
}


func Rule19Second(message string, index *int) error {
  err := Rule14(message, index)
  if err != nil {
    return err
  }

  err = Rule14(message, index)
  if err != nil {
    return err
  }

  return nil
}


func Rule12(message string, index *int) error {
  indexCopy := *index
  err := Rule12First(message, &indexCopy)

  if err == nil {
    *index = indexCopy
    return nil
  }

  err = Rule12Second(message, index)
  return err
}

func Rule12First(message string, index *int) error {
  err := Rule24(message, index)
  if err != nil {
    return err
  }

  err = Rule14(message, index)
  if err != nil {
    return err
  }

  return nil
}


func Rule12Second(message string, index *int) error {
  err := Rule19(message, index)
  if err != nil {
    return err
  }

  err = Rule1(message, index)
  if err != nil {
    return err
  }

  return nil
}


func Rule16(message string, index *int) error {
  indexCopy := *index
  err := Rule16First(message, &indexCopy)

  if err == nil {
    *index = indexCopy
    return nil
  }

  err = Rule16Second(message, index)
  return err
}

func Rule16First(message string, index *int) error {
  err := Rule15(message, index)
  if err != nil {
    return err
  }

  err = Rule1(message, index)
  if err != nil {
    return err
  }

  return nil
}


func Rule16Second(message string, index *int) error {
  err := Rule14(message, index)
  if err != nil {
    return err
  }

  err = Rule14(message, index)
  if err != nil {
    return err
  }

  return nil
}


func Rule31(message string, index *int) error {
  indexCopy := *index
  err := Rule31First(message, &indexCopy)

  if err == nil {
    *index = indexCopy
    return nil
  }

  err = Rule31Second(message, index)
  return err
}

func Rule31First(message string, index *int) error {
  err := Rule14(message, index)
  if err != nil {
    return err
  }

  err = Rule17(message, index)
  if err != nil {
    return err
  }

  return nil
}


func Rule31Second(message string, index *int) error {
  err := Rule1(message, index)
  if err != nil {
    return err
  }

  err = Rule13(message, index)
  if err != nil {
    return err
  }

  return nil
}


func Rule6(message string, index *int) error {
  indexCopy := *index
  err := Rule6First(message, &indexCopy)

  if err == nil {
    *index = indexCopy
    return nil
  }

  err = Rule6Second(message, index)
  return err
}

func Rule6First(message string, index *int) error {
  err := Rule14(message, index)
  if err != nil {
    return err
  }

  err = Rule14(message, index)
  if err != nil {
    return err
  }

  return nil
}


func Rule6Second(message string, index *int) error {
  err := Rule1(message, index)
  if err != nil {
    return err
  }

  err = Rule14(message, index)
  if err != nil {
    return err
  }

  return nil
}


func Rule2(message string, index *int) error {
  indexCopy := *index
  err := Rule2First(message, &indexCopy)

  if err == nil {
    *index = indexCopy
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

  err = Rule24(message, index)
  if err != nil {
    return err
  }

  return nil
}


func Rule2Second(message string, index *int) error {
  err := Rule14(message, index)
  if err != nil {
    return err
  }

  err = Rule4(message, index)
  if err != nil {
    return err
  }

  return nil
}


func Rule0(message string, index *int) error {
  err := Rule8(message, index)
  if err != nil {
    return err
  }

  err = Rule11(message, index)
  if err != nil {
    return err
  }

  return nil
}

func Rule13(message string, index *int) error {
  indexCopy := *index
  err := Rule13First(message, &indexCopy)

  if err == nil {
    *index = indexCopy
    return nil
  }

  err = Rule13Second(message, index)
  return err
}

func Rule13First(message string, index *int) error {
  err := Rule14(message, index)
  if err != nil {
    return err
  }

  err = Rule3(message, index)
  if err != nil {
    return err
  }

  return nil
}


func Rule13Second(message string, index *int) error {
  err := Rule1(message, index)
  if err != nil {
    return err
  }

  err = Rule12(message, index)
  if err != nil {
    return err
  }

  return nil
}


func Rule15(message string, index *int) error {
  indexCopy := *index
  err := Rule15First(message, &indexCopy)

  if err == nil {
    *index = indexCopy
    return nil
  }

  err = Rule15Second(message, index)
  return err
}

func Rule15First(message string, index *int) error {
  err := Rule1(message, index)
  if err != nil {
    return err
  }

  return nil
}


func Rule15Second(message string, index *int) error {
  err := Rule14(message, index)
  if err != nil {
    return err
  }

  return nil
}


func Rule17(message string, index *int) error {
  indexCopy := *index
  err := Rule17First(message, &indexCopy)

  if err == nil {
    *index = indexCopy
    return nil
  }

  err = Rule17Second(message, index)
  return err
}

func Rule17First(message string, index *int) error {
  err := Rule14(message, index)
  if err != nil {
    return err
  }

  err = Rule2(message, index)
  if err != nil {
    return err
  }

  return nil
}


func Rule17Second(message string, index *int) error {
  err := Rule1(message, index)
  if err != nil {
    return err
  }

  err = Rule7(message, index)
  if err != nil {
    return err
  }

  return nil
}


func Rule23(message string, index *int) error {
  indexCopy := *index
  err := Rule23First(message, &indexCopy)

  if err == nil {
    *index = indexCopy
    return nil
  }

  err = Rule23Second(message, index)
  return err
}

func Rule23First(message string, index *int) error {
  err := Rule25(message, index)
  if err != nil {
    return err
  }

  err = Rule1(message, index)
  if err != nil {
    return err
  }

  return nil
}


func Rule23Second(message string, index *int) error {
  err := Rule22(message, index)
  if err != nil {
    return err
  }

  err = Rule14(message, index)
  if err != nil {
    return err
  }

  return nil
}


func Rule28(message string, index *int) error {
  err := Rule16(message, index)
  if err != nil {
    return err
  }

  err = Rule1(message, index)
  if err != nil {
    return err
  }

  return nil
}

func Rule4(message string, index *int) error {
  err := Rule1(message, index)
  if err != nil {
    return err
  }

  err = Rule1(message, index)
  if err != nil {
    return err
  }

  return nil
}

func Rule20(message string, index *int) error {
  indexCopy := *index
  err := Rule20First(message, &indexCopy)

  if err == nil {
    *index = indexCopy
    return nil
  }

  err = Rule20Second(message, index)
  return err
}

func Rule20First(message string, index *int) error {
  err := Rule14(message, index)
  if err != nil {
    return err
  }

  err = Rule14(message, index)
  if err != nil {
    return err
  }

  return nil
}


func Rule20Second(message string, index *int) error {
  err := Rule1(message, index)
  if err != nil {
    return err
  }

  err = Rule15(message, index)
  if err != nil {
    return err
  }

  return nil
}


func Rule3(message string, index *int) error {
  indexCopy := *index
  err := Rule3First(message, &indexCopy)

  if err == nil {
    *index = indexCopy
    return nil
  }

  err = Rule3Second(message, index)
  return err
}

func Rule3First(message string, index *int) error {
  err := Rule5(message, index)
  if err != nil {
    return err
  }

  err = Rule14(message, index)
  if err != nil {
    return err
  }

  return nil
}


func Rule3Second(message string, index *int) error {
  err := Rule16(message, index)
  if err != nil {
    return err
  }

  err = Rule1(message, index)
  if err != nil {
    return err
  }

  return nil
}


func Rule27(message string, index *int) error {
  indexCopy := *index
  err := Rule27First(message, &indexCopy)

  if err == nil {
    *index = indexCopy
    return nil
  }

  err = Rule27Second(message, index)
  return err
}

func Rule27First(message string, index *int) error {
  err := Rule1(message, index)
  if err != nil {
    return err
  }

  err = Rule6(message, index)
  if err != nil {
    return err
  }

  return nil
}


func Rule27Second(message string, index *int) error {
  err := Rule14(message, index)
  if err != nil {
    return err
  }

  err = Rule18(message, index)
  if err != nil {
    return err
  }

  return nil
}


func Rule14(message string, index *int) error {
  if len(message) <= *index {
    return errors.New("out of bounds")
  }

  if string(message[*index]) == "b" {
    *index++
    return nil
  }
  return errors.New("Could not match")
}

func Rule21(message string, index *int) error {
  indexCopy := *index
  err := Rule21First(message, &indexCopy)

  if err == nil {
    *index = indexCopy
    return nil
  }

  err = Rule21Second(message, index)
  return err
}

func Rule21First(message string, index *int) error {
  err := Rule14(message, index)
  if err != nil {
    return err
  }

  err = Rule1(message, index)
  if err != nil {
    return err
  }

  return nil
}


func Rule21Second(message string, index *int) error {
  err := Rule1(message, index)
  if err != nil {
    return err
  }

  err = Rule14(message, index)
  if err != nil {
    return err
  }

  return nil
}


func Rule25(message string, index *int) error {
  indexCopy := *index
  err := Rule25First(message, &indexCopy)

  if err == nil {
    *index = indexCopy
    return nil
  }

  err = Rule25Second(message, index)
  return err
}

func Rule25First(message string, index *int) error {
  err := Rule1(message, index)
  if err != nil {
    return err
  }

  err = Rule1(message, index)
  if err != nil {
    return err
  }

  return nil
}


func Rule25Second(message string, index *int) error {
  err := Rule1(message, index)
  if err != nil {
    return err
  }

  err = Rule14(message, index)
  if err != nil {
    return err
  }

  return nil
}


func Rule22(message string, index *int) error {
  err := Rule14(message, index)
  if err != nil {
    return err
  }

  err = Rule14(message, index)
  if err != nil {
    return err
  }

  return nil
}

func Rule8(message string, index *int) error {
  err := Rule42(message, index)
  if err != nil {
    return err
  }

  return nil
}

func Rule26(message string, index *int) error {
  indexCopy := *index
  err := Rule26First(message, &indexCopy)

  if err == nil {
    *index = indexCopy
    return nil
  }

  err = Rule26Second(message, index)
  return err
}

func Rule26First(message string, index *int) error {
  err := Rule14(message, index)
  if err != nil {
    return err
  }

  err = Rule22(message, index)
  if err != nil {
    return err
  }

  return nil
}


func Rule26Second(message string, index *int) error {
  err := Rule1(message, index)
  if err != nil {
    return err
  }

  err = Rule20(message, index)
  if err != nil {
    return err
  }

  return nil
}


func Rule18(message string, index *int) error {
  err := Rule15(message, index)
  if err != nil {
    return err
  }

  err = Rule15(message, index)
  if err != nil {
    return err
  }

  return nil
}

func Rule7(message string, index *int) error {
  indexCopy := *index
  err := Rule7First(message, &indexCopy)

  if err == nil {
    *index = indexCopy
    return nil
  }

  err = Rule7Second(message, index)
  return err
}

func Rule7First(message string, index *int) error {
  err := Rule14(message, index)
  if err != nil {
    return err
  }

  err = Rule5(message, index)
  if err != nil {
    return err
  }

  return nil
}


func Rule7Second(message string, index *int) error {
  err := Rule1(message, index)
  if err != nil {
    return err
  }

  err = Rule21(message, index)
  if err != nil {
    return err
  }

  return nil
}


func Rule24(message string, index *int) error {
  err := Rule14(message, index)
  if err != nil {
    return err
  }

  err = Rule1(message, index)
  if err != nil {
    return err
  }

  return nil
}
