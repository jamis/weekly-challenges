# Weekly Challenge #2: Generate Random Names

https://medium.com/@jamis/weekly-programming-challenge-2-33ef134b39cd

I'm implemented both normal and hard mode this time. Normal mode hard-codes
the grammar, which encodes a subset of the syllables found in Sindarin
names and uses them to randomly generate a list of Sindarin-ish names,
ten at a time. The grammar itself is included as a comment at the top of
`normal-mode.rb`.

To run it:

```sh
$ ruby normal-mode.rb
 1. calam
 2. moredviel
 3. par-galnurbalsa
 ...
```

My hard-mode submission accepts a file in EBNF format, and produces a list
of strings generated from the provided grammar. I've actually extended the
EBNF grammar to add some syntax to make it possible to tweak the behavior
of the generator by specifying probabilities for optional items, minimum
and maximum counts for repeats, and weights for items in an alternation:

```bnf
start = first/5 | second/2 | third
first = { 'a' }>0<5
second = 'b' , [ 'c' ]%25
third = 'd' | ( first , 'b' )/3 | { 'g' }>2%25
```

The slash `/` assigns a weight to the element. For `start`, then, the total
of the weights of the alternations there is `5 + 2 + 1` (1 is the default
weight if one is not assigned), or `8`. Thus, `first` has 5 chances out of 8
of being selected, `second` has 2 of 8, and third just 1 of 8.

The `>` assigns a minimum, saying that the given element must appear more
times than the given value. Likewise, '<' assigns a maximum, saying that
the element must appear fewer times than the given value. Thus, for
`first`, the `'a'` terminal must appear more than zero, and less than 5
times.

Lastly, `%` assigns a probability, saying what percentage chance the element
has of appearing. For `second`, the `'c'` terminal is optional, appearing
25% of the time. (The default is 50%.) This can also be used with repeats,
indicating what chance the element has of repeating.

To run my hard-mode implementation:

```sh
$ ruby hard-mode.rb sindarin.ebnf
 1. nardorviel
 2. pel-nanviel
 3. farryn
 ...
```

Several other example grammars are provided, as well:

* `lisp.ebnf` -- randomly produces simple lisp programs.
* `gibberish.ebnf` -- creates random paragraphs of text.
* `ebnf.ebnf` -- random generates EBNF grammars!


## LICENSE

This code is provided as-is, with no guarantees or promises of support of
any kind, implied or otherwise. You may use it however you wish, the sole
exception that you may not claim authorship or any kind of financial control
over the code.


## AUTHOR

Jamis Buck <jamis@jamisbuck.org>
