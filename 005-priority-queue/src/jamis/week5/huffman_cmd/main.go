package main

import (
  "jamis/week5/huffman"
)

func main() {
  queue := huffman.Prioritize("but soft what light through yonder window breaks it is the east and juliet is the sun")
  tree := huffman.Encode(queue)
  huffman.Dump(&tree, "")
}
