---
layout: post
title:  "Episode 12 & 13: Fade out and clean up"
date:   2021-10-16 18:00:00 -0400
ref: tetris-fade-out
lang: en
permalink: /elm/en/tetris-fade-out
---

<img src="/assets/posts/tetris-fade-out/fade.gif" style="float:left; margin: 5px 10px 10px 0"/>
In [episode 12(1h:25m)](https://www.youtube.com/watch?v=7HhOdCNfEj4) I started with building a simple score tracker. Adding gradual fading became a bit of a cliffhanger, because I introduced a gnarly bug that I was only able to resolve in [episode 13 (1h:20)](https://www.youtube.com/watch?v=OfNkjrJGtyc).
I used this as motivation to clean up and reorganize the code with the help of the glorious [*Conquer of Completion*](https://github.com/neoclide/coc.nvim) Vim plugin.

For episode 12 I created a single [commit](https://github.com/axelerator/elm-tetris/commit/bcb5e904ecdc7127bb379a836ecfdf874d1552f6) as before. It's the head of the [episode12 branch](https://github.com/axelerator/elm-tetris/tree/episode12).

For the changes of episode 13, I went with a different approach. Since I reorganized the code a lot a large number of lines changed. To keep them comprehensible I separated them into multiple smaller commits. Of course, there is still also the [episode13 branch](https://github.com/axelerator/elm-tetris/tree/episode13) that represents the state of the code after that episode. To see only the steps I did in that episode you can check out this [*pull request*](https://github.com/axelerator/elm-tetris/pull/1/commits).

<iframe width="560" height="315" src="https://www.youtube.com/embed/7HhOdCNfEj4" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

<iframe width="560" height="315" src="https://www.youtube.com/embed/OfNkjrJGtyc" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

---

Content:

  - [Score tracking](#scoring)
  - [Fading cleared lines](#fading)
  - [Clean up](#cleanup)

---


### <a name="scoring" /> Score tracking

To be able to keep score I added a new [type `Score`](https://github.com/axelerator/elm-tetris/commit/bcb5e904ecdc7127bb379a836ecfdf874d1552f6#diff-2dd82f159d96fbfcd26fb7d885d25e0d54efde9e19a42494b416fa84a5aca568R39) that I use in the `GameDetails`.
I implemented it in the most simple way: Clearing 1 row = 1 Point. The real Tetris has a much more sophisticated scoring algorithm (Source: [Tetris Wiki](https://tetris.fandom.com/wiki/Scoring))

| Level |Points for 1 line | 2 lines | 3 lines | 4 lines |
|:-----:|:----------------:|:-------:|:-------:|:-------:|
|0 | 40 | 100 | 300 | 1200 |
|1 | 80 | 200 | 600 | 2400 |
|2 | 120 | 300 | 900 | 3600 |
|9 | 400 | 1000 | 3000 | 12000 |

`level(n) =  40 * (n + 1) 100 * (n + 1) 300 * (n + 1) 1200 * (n + 1)`

---

### <a name="fading" /> Fading cleared lines

To be able to fade a row I [added a new variant `FadingRow`](https://github.com/axelerator/elm-tetris/commit/bcb5e904ecdc7127bb379a836ecfdf874d1552f6#diff-2dd82f159d96fbfcd26fb7d885d25e0d54efde9e19a42494b416fa84a5aca568R82) to the `Row` type.

```Elm
type Row
    = Row (List Field)
    | FadingRow (List Field) Opacity
```
A fading row represents a row that was logically removed but is visually still present.
Next to the tile information it also contains a value for the opacity.

To be able to progress the fading out in the speed I desire I need to update our model more often. To achieve that we're now firing the `GravityTick` every [*30* instead of every *100*](https://github.com/axelerator/elm-tetris/commit/bcb5e904ecdc7127bb379a836ecfdf874d1552f6#diff-2dd82f159d96fbfcd26fb7d885d25e0d54efde9e19a42494b416fa84a5aca568R548) milliseconds.
For every tick we decrease the opacity of all fading rows a bit with the [`progressFading` function](https://github.com/axelerator/elm-tetris/commit/bcb5e904ecdc7127bb379a836ecfdf874d1552f6#diff-2dd82f159d96fbfcd26fb7d885d25e0d54efde9e19a42494b416fa84a5aca568R462) until they've completely vanished.

It was when I tried to integrate `progressFading` in all the right places that I introduced the error that eventually made me give up that day. As part of updating the [`eraseCompleteRows` function](https://github.com/axelerator/elm-tetris/commit/bcb5e904ecdc7127bb379a836ecfdf874d1552f6#diff-2dd82f159d96fbfcd26fb7d885d25e0d54efde9e19a42494b416fa84a5aca568R531) I reset the `currentPiece`.
The [first change in episode 13](https://github.com/axelerator/elm-tetris/commit/4bac5a1f167b593b9f949ff66a8868b8f7c5e5b2) resolves the error and finally the fading works as expected.


---

### <a name="cleanup" /> Clean up

The rest of that episode I spend separating the general application from the 'pure' game logic. Though I wouldn't go as far as calling it a *refactoring* since I've been mainly moving functions from one module to another.

For that task, I put a new tool of my development environment to use. [Conquer of Completion](https://github.com/neoclide/coc.nvim) (short *CoC*) is a Vim plugin that uses the [Language Server Protocol](https://microsoft.github.io/language-server-protocol/overviews/lsp/overview/) to support the developer with language-specific hints. The same protocol is used in Visual Studio Code for many languages for autocompletion and other features like organizing inputs.

With the help of *CoC* execution operations like moving functions to a different module can be executed much more efficiently. Tedious subtasks like updating imports and removing unused code are reduced to executing the actions proposed by the plugin inline.

Most of the significant steps to set up *CoC* with Elm for Vim are outlined in the  [Elm Language Server project](https://github.com/elm-tooling/elm-language-server).

I think I'll do a special episode soon showing how to set up a complete Elm development environment with Vim from scratch.
