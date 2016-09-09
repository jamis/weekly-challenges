# Weekly Challenge #6: Make Some Noise

https://medium.com/@jamis/weekly-programming-challenge-6-83fa37e9e737

The goal of this challenge was to implement a program that generates
_Perlin noise_. I haven't done anything C in a long, long while, so I
decided to stretch those muscles (and I got to remember just how much
I love C! Seriously. It's one of my favorite proglangs.)

As I'd never implemented Perlin noise before, it was tricky to know what
the "hard mode" goals ought to be. I know better now, but going just from
what the challenge requirements were, I earned three points:

* **1 point** for normal mode (2D perlin noise, drawn as an image)
* **1 point** for 3D perlin noise
* **1 point** for displaying the noise as terrain (top-down, map-style).

To build it:

```sh
$ make
``

This will build the source and produce an executable named `noise`. To
run it:

```sh
$ ./noise -h
usage: ./noise [-f num] [-c [gf]] [-r seed]
       [-s num] [-x num] [-y num] [-z num]
       [-W num] [-H num]
       [-F num] [-o num] [-p num]
       [-n name.ppm]

  -f num    :: number of frames to generate
  -c [gftc] :: color scheme to use (g=grayscale, f=fire, t=terrain, c=clouds)
  -r seed   :: random seed to initialize PRNG
  -s num    :: floating point number for xyz speed
  -x num    :: floating point number for x speed
  -y num    :: floating point number for y speed
  -z num    :: floating point number for z speed
  -w num    :: width of frame to generate
  -h num    :: height of frame to generate
  -F num    :: initial frequency for first octave
  -o num    :: number of octaves to compute
  -p num    :: persistence value for subsequent octaves
  -n name   :: file name to use for frames

$ ./noise -n noise.ppm
```

I had a lot of fun with this challenge. I'd like to spend some more time
with the algorithm, and try to figure out how to make the noise tilable.


## LICENSE

This code is provided as-is, with no guarantees or promises of support of
any kind, implied or otherwise. You may use it however you wish, the sole
exception that you may not claim authorship or any kind of financial control
over the code.


## AUTHOR

Jamis Buck <jamis@jamisbuck.org>
