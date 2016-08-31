package huffman

import (
  "bufio"
  "fmt"
  "io"
  "regexp"
  "strings"
)

type Tokenizer interface {
  NextToken() string
}

type CharWiseTokenizer struct {
  reader io.RuneReader
}

type WordWiseTokenizer struct {
  scanner *bufio.Scanner
  pattern *regexp.Regexp
}

func NewCharWiseTokenizer(reader io.RuneReader) *CharWiseTokenizer {
  return &CharWiseTokenizer { reader }
}

func (tok *CharWiseTokenizer) NextToken() string {
  rune, _, err := tok.reader.ReadRune()

  if err != nil { return "" }
  return fmt.Sprintf("%c", rune)
}

func NewWordWiseTokenizer(reader io.Reader) *WordWiseTokenizer {
  scanner := bufio.NewScanner(reader)
  scanner.Split(bufio.ScanWords)

  regex := regexp.MustCompile("[^a-zA-Z]")

  return &WordWiseTokenizer { scanner, regex }
}

func (tok *WordWiseTokenizer) NextToken() string {
  if tok.scanner.Scan() {
    text := tok.scanner.Text()
    result := strings.ToLower(tok.pattern.ReplaceAllString(text, ""))
    if len(result) < 1 { result = " " }
    return result
  }

  return ""
}
