package main

import (
  "fmt"
  "math/rand"
  "jamis/week5/binary_heap"
)

func compareInt(a int, b int) bool {
  return a > b
}

func main() {
  heap := binary_heap.NewHeap(compareInt)

  for i := 0; i < 100; i++ {
    heap.Insert("a", rand.Intn(1000))
  }

  for !heap.IsEmpty() {
    fmt.Println(heap.Extract())
  }
}
