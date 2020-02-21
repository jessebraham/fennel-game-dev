# Game Development with Fennel and LÖVE

Experiments developing 2D games using [Fennel] and [LÖVE].

This repository contains the source code to accompany [Game Development with Fennel and LÖVE]. For a more in-depth explanation please refer to the post.

[Fennel]: https://fennel-lang.org/
[LÖVE]: https://love2d.org/
[Game Development with Fennel and LÖVE]: https://beta7.io/posts/game-development-with-fennel-and-love.html

## Quickstart

Make sure you have installed LÖVE on your system, and that `love` is available on your `PATH`. Visit [the LÖVE website] for details.

Next, check out the repository and fetch the dependencies. At this time, only `fennel.lua` is required, which can be saved directly from [the Fennel repository], or downloaded using the included `deps.sh` script.

```bash
$ git clone https://github.com/jessebraham/fennel-game-dev
$ cd fennel-game-dev/
$ ./deps.sh
```

There are three games within this repository. Each are briefly documented below.

### Snake

Based on the [snake tutorial] from Simple Game Tutorials. To run:

[snake tutorial]: https://simplegametutorials.github.io/snake/

```bash
$ love snake
```

### Bird

Based on the [bird tutorial] from Simple Game Tutorials. To run:

[bird tutorial]: https://simplegametutorials.github.io/bird/

```bash
$ love bird
```

### Blocks

Based on the [blocks tutorial] from Simple Game Tutorials. To run:

[blocks tutorial]: https://simplegametutorials.github.io/blocks/

```bash
$ love blocks
```

[the LÖVE website]: https://love2d.org/
[the Fennel repository]: https://github.com/bakpakin/Fennel
