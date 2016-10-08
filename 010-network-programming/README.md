# Weekly Challenge #10: Network Programming

http://weblog.jamisbuck.org/2016/10/1/weekly-programming-challenge-10.html

I gave this one a try in Erlang, but sadly, the week was too busy to do
more than normal mode. To run it, start the server like so:

```sh
$ ./src/normal-server 1234
```

Then start the client:

```sh
$ ./src/normal-client localhost 1234
```

It will print "hello world" backwards, as the client sends "hello world",
and the server reverses it and sends it back. Not super impressive, I know,
but one of these days I want to come back to this and give hard mode a
fair shake!


## LICENSE

This code is provided as-is, with no guarantees or promises of support of
any kind, implied or otherwise. You may use it however you wish, the sole
exception that you may not claim authorship or any kind of financial control
over the code.


## AUTHOR

Jamis Buck <jamis@jamisbuck.org>
