package main

import (
  "os"
  "bufio"
  "fmt"
  "jamis/week5/huffman"
)

func main() {
  if len(os.Args) < 2 {
    fmt.Println("Please specify a file to open")
  } else {
    file, err := os.Open(os.Args[1])
    if err != nil {
      fmt.Println("Could not open file -", err)
    } else {
      var tokenizer huffman.Tokenizer
      var alphabet = "01"

      reader := bufio.NewReader(file)

      if len(os.Args) > 2 && os.Args[2] == "-w" {
        tokenizer = huffman.NewWordWiseTokenizer(reader)
      } else {
        tokenizer = huffman.NewCharWiseTokenizer(reader)
      }

      if len(os.Args) > 3 { alphabet = os.Args[3] }

      queue := huffman.Prioritize(tokenizer)
      tree := huffman.Encode(queue, len(alphabet))
      huffman.Dump(&tree, alphabet, "")
    }
  }
}
