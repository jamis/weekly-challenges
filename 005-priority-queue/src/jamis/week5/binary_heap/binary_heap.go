package binary_heap

type Node struct {
  parent, left, right *Node
  value *interface{}
  priority int
}

type Heap struct {
  root *Node
  higher func (interface{}, interface{}) bool
}

func NewHeap(higher func (interface{}, interface{}) bool) *Heap {
  heap := new(Heap)
  heap.higher = higher
  return heap
}

func (heap *Heap) IsEmpty() bool {
  return heap.root == nil
}
