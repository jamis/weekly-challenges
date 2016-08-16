# Weekly Challenge #3: Solving Mazes

https://medium.com/@jamis/weekly-programming-challenge-3-932b16ddd957

For this one, I decided I wanted to try my hand at Elixir, and I'm
glad I did! I learned a lot. Still, I'm sure my submission is full
of wierd idioms and poor practices, so I welcome any comments and
feedback.

I implemented hard-mode, using a breadth-first search to find the shortest
path through the given maze. This will work even on mazes with multiple
solutions ("multiply-connected" or "braided" mazes).

To run it:

```sh
$ elixir hard-mode.ex path/to/maze.txt
north
north
west
west
west
west
south
...
```


## LICENSE

This code is provided as-is, with no guarantees or promises of support of
any kind, implied or otherwise. You may use it however you wish, the sole
exception that you may not claim authorship or any kind of financial control
over the code.


## AUTHOR

Jamis Buck <jamis@jamisbuck.org>
