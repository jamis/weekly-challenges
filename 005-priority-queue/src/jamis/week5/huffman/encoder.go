package huffman

import(
  "fmt"
  "strings"
  "jamis/week5/binary_heap"
)

type node struct {
  parent *node
  children []*node
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
    heap.Insert(node { nil, nil, rune, weight }, weight)
  }

  return heap
}

func Encode(heap *binary_heap.Heap, arity int) node {
  for {
    t, _ := heap.Extract()
    a := t.(node)
    if heap.IsEmpty() { return a }

    parent := node {}

    parent.children = make([]*node, 1, arity)
    parent.children[0] = &a

    parent.weight = a.weight
    parent.value = a.value

    for i := 1; i < arity; i++ {
      t, _ = heap.Extract()
      b := t.(node)
      b.parent = &parent
      parent.children = append(parent.children, &b)
      parent.weight += b.weight
      parent.value += ":" + b.value
      if heap.IsEmpty() { break }
    }

    heap.Insert(parent, parent.weight)
  }
}

func Dump(root *node, alphabet string, tag string) {
  if root.children != nil {
    if len(root.children) > len(alphabet) {
      panic("alphabet isn't long enough!")
    }

    for index, child := range root.children {
      Dump(child, alphabet, tag + alphabet[index:index+1])
    }
  } else {
    fmt.Println(root.value, tag)
  }
}
