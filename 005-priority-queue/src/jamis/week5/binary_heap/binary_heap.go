package binary_heap

type Node struct {
  value interface{}
  priority int
}

type Heap struct {
  list []Node
  higher func (int, int) bool
}

func NewHeap(higher func (int, int) bool) *Heap {
  heap := new(Heap)
  heap.list = make([]Node, 0, 10)
  heap.higher = higher
  return heap
}

func (heap *Heap) IsEmpty() bool {
  return len(heap.list) == 0
}

func (heap *Heap) Insert(value interface{}, priority int) {
  heap.list = append(heap.list, Node { value, priority })
  heap.upHeapFrom(len(heap.list)-1)
}

func (heap *Heap) Extract() (interface{}, int) {
  if len(heap.list) == 0 {
    return nil, 0
  } else {
    root := heap.list[0]
    heap.list[0] = heap.list[len(heap.list)-1]
    heap.list = heap.list[:len(heap.list)-1]
    heap.downHeapFrom(0)
    return root.value, root.priority
  }
}

func (heap *Heap) Peek() (interface{}, int) {
  if len(heap.list) > 0 {
    return heap.list[0].value, heap.list[0].priority
  } else {
    return nil, 0
  }
}

func (heap *Heap) upHeapFrom(child int) {
  if child > 0 {
    parent := (child - 1) >> 1

    if heap.higher(heap.list[child].priority, heap.list[parent].priority) {
      heap.list[child], heap.list[parent] = heap.list[parent], heap.list[child]
      heap.upHeapFrom(parent)
    }
  }
}

func (heap *Heap) downHeapFrom(root int) {
  left := root * 2 + 1
  right := root * 2 + 2
  preferred_root := root

  if left < len(heap.list) && heap.higher(heap.list[left].priority, heap.list[preferred_root].priority) {
    preferred_root = left
  }

  if right < len(heap.list) && heap.higher(heap.list[right].priority, heap.list[preferred_root].priority) {
    preferred_root = right
  }

  if preferred_root != root {
    heap.list[preferred_root], heap.list[root] = heap.list[root], heap.list[preferred_root]
    heap.downHeapFrom(preferred_root)
  }
}
