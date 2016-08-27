# Weekly Challenge #4: Drawing Lines

https://medium.com/@jamis/weekly-programming-challenge-4-7fe42f28d5d4

I think I'm going to try and do a different programming language for
each of these. This time, it was Rust. I'm glad I gave it a try, but I
don't think I'll do any more with Rust. I found it far harder to deal
with lifetimes and borrowing than I think it should be. Still, if anyone
can make a good argument why I should try it further, I'm all ears!

I implemented hard-mode, earning a total of three points:

* **1 point** for normal mode (bresenham algorithm, and save as PPM file),
* **1 point** for line thickness (still not perfectly happy with the implementation but it works), and
* **1 point** for line styles (configurable dash length)

To run it:

```sh
$ cargo run
```

This will create a `lines.ppm` file in the current directory, demonstrating
lines of variable width and angle, as well as lines of varying dash lengths.


## LICENSE

This code is provided as-is, with no guarantees or promises of support of
any kind, implied or otherwise. You may use it however you wish, the sole
exception that you may not claim authorship or any kind of financial control
over the code.


## AUTHOR

Jamis Buck <jamis@jamisbuck.org>
