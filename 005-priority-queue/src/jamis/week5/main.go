package main

import (
  "fmt"
  "math/rand"
  "time"
  "jamis/week5/binary_heap"
)

func maxHeap(a int, b int) bool {
  return a > b
}

func minHeap(a int, b int) bool {
  return a < b
}

func minHeapPreferEven(a int, b int) bool {
  if a % 2 == b % 2 {
    return a < b
  } else if a % 2 == 0 {
    return true
  }

  return false
}

func main() {
  rand.Seed(time.Now().UTC().UnixNano())
  heap := binary_heap.NewHeap(minHeapPreferEven)

  for i := 0; i < 1000; i++ {
    heap.Insert(fmt.Sprintf("%3d", i), rand.Intn(10000))
  }

  for !heap.IsEmpty() {
    fmt.Println(heap.Extract())
  }
}
