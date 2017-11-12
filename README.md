piet∞
=====
Infinitely-recursive procedurally-generated [Piet][1]-esque compositions.

| ![SS0](https://github.com/boramalper/piet-inf/raw/master/sss/ss0.png "The Composition") | **->** | ![SS1](https://github.com/boramalper/piet-inf/raw/master/sss/ss1.png "Sub-Composition on the top-left corner of the Composition") |
|:---------------------------------------------------------------------------------------:|:------:|:---------------------------------------------------------------------------------------------------------------------------------:|

[1]: https://en.wikipedia.org/wiki/Piet_Mondrian

Running
-------
You'll need [Haskell Platform][2] to run **piet∞**.

1. Install dependencies

       cabal install --only-dependencies

2. Run

       cabal run

__Changing the resolution and the (recursive) render depth__

    cabal run [SIDE_LENGTH=1080] [RENDER_DEPTH=8]

By default, **piet∞** uses a 1080x1080 square canvas with render depth 8.

[2]: https://www.haskell.org/platform/

Usage
-----
```
╔═══╤═══╤═══╗
║ 7 │ 8 │ 9 ║  Use keys 1-9 to "zoom" to the enumerated *cell*.
╟───┼───┼───╢
║ 4 │ 5 │ 6 ║
╟───┼───┼───╢
║ 1 │ 2 │ 3 ║
╚═══╧═══╧═══╝
```
```
╔═══════╤═══╗
║ 7   8 │ 9 ║  To zoom to a merged cell, you can use any of the keys it spans.
║  ANY  ├───╢
║ 4   5 │ 6 ║  Press 0 to zoom out.
╟───┬───┼───╢
║ 1 │ 2 │ 3 ║
╚═══╧═══╧═══╝
```
```
╔═══════╤═══╗
║ 7   8 │ 9 ║  Only square cells are zoomable.
║  ANY  ├───╢
║ 4   5 │ 6 ║
╟───┬───┴───╢
║ 1 │       ║
╚═══╧═══════╝
```
```
╔═══════════╗
║           ║  If there are no square cells either zoom out, or -if you just run
╟───────────╢  the program- quit by pressing ESC and restart.
║           ║
╟───────────╢
║           ║
╚═══════════╝
```
BUGS & TODOs
------------
* Make sure that every world (*i.e.* composition) has at least one square tile
  whilst generating borders, so that the user won't see any *dead-ends*.
* While adjusting vertical borders according to horizontal ones to fit the
  criteria, introduce some randomness there as well so that the structures can
  be more variable.
* Instead of generating horizontal borders first and adjusting vertical borders
  accordingly to fit the criteria, we can also (I think) choose any two borders
  among all four, generate them randomly, and adjust the remaining two
  accordingly; so that there the structures can be more variable.
* Zooming animations would be amazing!
* Ensure that, for instance, no two adjacent non-square cells in a world have
  the same color, to increase aesthetics.
  * I excluded non-square cells because not only it would be too hard to
    implement, but that promise would also introduce interdependency between
    a parent world and its subworlds, which is undesirable for many reasons
    (See the next point for a possible reason.)
* Try implementing infinite zoom-out as well. You might have to introduce some
  irregularities in the code to handle the new cases.
* As a challenge, try implementing an infinitely large canvas where you can move
  around.
  * Consider how to make the movement animated as well!

```
$ cloc src/
       7 text files.
       7 unique files.
       0 files ignored.

http://cloc.sourceforge.net v 1.60  T=0.03 s (249.1 files/s, 17544.5 lines/s)
-------------------------------------------------------------------------------
Language                     files          blank        comment           code
-------------------------------------------------------------------------------
Haskell                          7             62             54            377
-------------------------------------------------------------------------------
SUM:                             7             62             54            377
-------------------------------------------------------------------------------
```

> I would have written a shorter letter, but I did not have the time.

Blaise Pascal

Copyright & License
-------------------
Copyright © 2017, Mert Bora ALPER <bora@boramalper.org>

All rights reserved.

Licensed under 2-clause BSD license, see [`LICENSE`](./LICENSE) for details.

----

*Civanıma, sevgilerimle.*
