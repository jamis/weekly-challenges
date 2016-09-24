# Weekly Challenge #8: Simple Parser and Interpreter

http://weblog.jamisbuck.org/2016/9/17/weekly-programming-challenge-8.html

Here, we got to implement a parser and interpreter for a simple calculator
grammar. I decided to be brave and give it a go in Haskell, and for the most
part, I think I succeeded! It may not be the most idiomatic code (and I'd
certainly welcome comments and advice in that regard), but I'm calling it
"good enough".

You'll need [ghc](https://www.haskell.org/ghc/) installed. Once you do,
building the calculator is simple:

```sh
$ ghc -o calc src/Calc.hs
```

You then run the `calc` executable, passing an expression that you want to
evaluate:

```sh
$ ./calc "1 + 2"
3.0
$ ./calc "2 * (5 + 2)"
14.0
$ ./calc "pi=3.141592; r=2.5; pi * r ^ 2"
```

I successfully implemented normal mode (basic arithmetic calculator) for
one point, as well as exponentiation (one point), variables (one point),
and multi-expressions (one point).  I had hoped to implement ternary
expressions and built-in functions (at least), but didn't quite get there.
Ultimately, I got **four points** this week.

## LICENSE

This code is provided as-is, with no guarantees or promises of support of
any kind, implied or otherwise. You may use it however you wish, the sole
exception that you may not claim authorship or any kind of financial control
over the code.


## AUTHOR

Jamis Buck <jamis@jamisbuck.org>
