package huffman

import(
  "fmt"
  "strings"
  "jamis/week5/binary_heap"
)

type node struct {
  parent *node
  left *node
  right *node
  value string
  weight int
}

func minHeap(a int, b int) bool {
  return a < b
}

func Prioritize(text string) *binary_heap.Heap {
  runes := strings.Split(text, "")
  counter := make(map[string]int)
  total := len(text)

  for _, rune := range runes {
    counter[rune] += 1
  }

  heap := binary_heap.NewHeap(minHeap)

  for rune, count := range counter {
    weight := 1000 * count / total
    heap.Insert(node { nil, nil, nil, rune, weight }, weight)
  }

  return heap
}

func Encode(heap *binary_heap.Heap) node {
  for {
    var a, b node

    t, _ := heap.Extract()
    a = t.(node)
    if heap.IsEmpty() { return a }

    t, _ = heap.Extract()
    b = t.(node)

    n := node { nil, &a, &b, a.value + ":" + b.value, a.weight+b.weight }
    a.parent = &n
    b.parent = &n

    heap.Insert(n, n.weight)
  }
}

func Dump(root *node, tag string) {
  if root.left != nil {
    Dump(root.left, tag + "0")
    Dump(root.right, tag + "1")
  } else {
    fmt.Println(root.value, tag)
  }
}
