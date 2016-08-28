package main

import (
  "fmt"
  "jamis/week5/binary_heap"
)

func compareInt(a interface{}, b interface{}) bool {
  i1 := a.(int)
  i2 := b.(int)

  return i1 > i2
}

func main() {
  heap := binary_heap.NewHeap(compareInt)

  fmt.Println(heap.IsEmpty())
}
