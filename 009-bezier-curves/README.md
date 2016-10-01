# Weekly Challenge #9: Bezier Curves

http://weblog.jamisbuck.org/2016/9/24/weekly-programming-challenge-9.html

Bezier curves! I went with Swift (and Xcode) to produce a Mac OSX app that
lets you play with Bezier curves of arbitrary degree. It could be a bit
more polished, but for my first serious OSX app, I think it turned out
okay.

You'll need Xcode to build it. Just open `BezierDemo.xcodeproj` in Xcode,
and run it... Hopefully it builds without problem!

The supported functions are:

1. Quadratic curves (three control points). The curve shown when the app
   starts, is quadratic.
2. Cubic curves (and higher). Simply click the "add point" button in the
   tool bar to take the current curve and elevate its degree by one. You'll
   get the same curve, but with an extra control point.
3. Rational curves. Shift-click and drag on a control point to increase or
   decrease its weight. The point will grow bigger or smaller to reflect
   the relative weight.
4. Curve splitting with de Casteljau's algorithm. Select the curve you
   want to split, click on the point on the curve where you want it split,
   and then click the "split curve" button in the toolbar.

I successfully implemented normal mode (quadratic curves) for
one point, as well as cubic curves (one point), rational curves (one point),
and curve splitting (one point). I also implemented an interactive UI for
playing with the curves (three points). Ultimately, I got **seven points**
this week.


## LICENSE

This code is provided as-is, with no guarantees or promises of support of
any kind, implied or otherwise. You may use it however you wish, the sole
exception that you may not claim authorship or any kind of financial control
over the code.


## AUTHOR

Jamis Buck <jamis@jamisbuck.org>
