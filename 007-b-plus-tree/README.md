# Weekly Challenge #7: B+ Trees

https://medium.com/@jamis/weekly-programming-challenge-7-286640364537

The goal of this challenge is to implement a B+tree, at least the search
and insert functionality. It's been a long time since I implemented a B+tree,
and I had a blast? My language of choice this time was Javascript.

My reference implementation (src/bplus-tree.js) met the minimum requirement
for normal mode (one point), and linked the leaf nodes together (another point),
and used a binary search to search the children of a node (another point).

After that, I also implemented the algorithms as a state machine
(src/illustrated-bplus-tree.js), with the intent that the tree's algorithms
could be animated graphically. This version did not implement the search
algorithm, but it did implement efficient bulk loading (another point),
and--if I weren't the judge :)--I'd say the index.html file qualifies for
"surprise me". The animation is pretty fun. :)

To run them:

```sh
$ NODE_PATH=libs node run.js
...
```

This will populate a tree with 10,000 random values, display the result
of searching for one of them, display the tree itself, and then display
the result of a "range" search (showing all values between two keys).

```sh
$ NODE_PATH=libs node run-state.js
...
```

This will use the state machine version of the algorithm, inserting
twenty keys into the tree, and emitting all of the events that occur
as they are inserted.

Lastly,

```sh
$ open index.html
```

This page will display a pre-built B+ tree as an SVG illustration. Clicking
the "Add value" button will begin the process of adding a new (random) value
to the tree, allowing you to either run the algorithm with a single click,
or to step through the algorithm and watch the value being inserted.

## LICENSE

This code is provided as-is, with no guarantees or promises of support of
any kind, implied or otherwise. You may use it however you wish, the sole
exception that you may not claim authorship or any kind of financial control
over the code.


## AUTHOR

Jamis Buck <jamis@jamisbuck.org>
