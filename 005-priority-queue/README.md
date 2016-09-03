# Weekly Challenge #5: Priority Queues and Binary Heaps

https://medium.com/@jamis/weekly-programming-challenge-5-e7677458f646

This is my attempt to implement a priority queue in Go. As I've never
coded in Go before, there may be plenty of non-idiomatic code. I would
appreciate feedback from those with more experience!

I implemented hard mode, and earned 5 points:

* **1 point** for normal mode (binary heap and priority queue)
* **1 point** for a configurable sorting function
* **1 point** for supporting arbitrary data types
* **2 points** for implementing a Huffman coder with the priority queue

To run it:

```sh
$ ./build.sh
```

This will build two binaries in the `bin` directory:

* `bin/week5` -- this simply adds 10,000 random numbers to the queue
  and uses a custom sorting function to remove and display them in
  sorted order, with even numbers sorted before odd numbers, and smaller
  before greater.
* `bin/huffman_cmd` -- this will accept a filename as an argument, as well
  as (optionally) `-w` for word-wise parsing, or `-c` for char-wise parsing,
  and a list of characters to use as the alphabet, when constructing the
  Huffman coding. The program then parses the file, breaking it into symbols
  either by words (`-w`) or by character, and then emits a Huffman coding
  using the provided alphabet (or "01" by default).

For example:

```sh
$ bin/huffman_cmd README.md
p 00000
u 00001
n 0001
t 0010
g 001100
w 001101
l 00111
r 0100
...

$ bin/huffman_cmd README.md -w
c 00000000
understand 00000001
earned 00000010
custom 00000011
sorting 0000010
default 00000110
not 00000111
...

$ bin/huffman_cmd README.md -w ABCDEFGHIJKLMNOPQRSTUVWXYZ
and A
the B
  C
guarantees DA
characters DB
them DC
that DD
be DE
asis DF
...
```

I *really* liked this challenge. The Huffman coder was remarkably
straightforward once I understand the algorithm, and it was very fun
to play with.


## LICENSE

This code is provided as-is, with no guarantees or promises of support of
any kind, implied or otherwise. You may use it however you wish, the sole
exception that you may not claim authorship or any kind of financial control
over the code.


## AUTHOR

Jamis Buck <jamis@jamisbuck.org>
