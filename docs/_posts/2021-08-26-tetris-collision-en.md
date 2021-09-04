---
layout: post
title:  "Episode 6 & 7: Collision detection and Test Driven Development"
date:   2021-08-26 20:00:00 -0400
ref: tetris-collision
lang: en
permalink: /elm/en/tetris-collision
---

<img src="/assets/posts/tetris-collision/collision_cropped.gif" alt="collision detection" style="float: left; padding-right: 5px"/>
This article is the summary of the last two episodes. Tetris-wise I'm trying to implement the functionality that lets the current piece rest on the ground or other previously dropped pieces. After I introduced a gnarly logic error in [episode 6](https://www.youtube.com/watch?v=KXtmFh0C-9s) I decided to start from scratch in [episode 7](https://www.youtube.com/watch?v=ZXMQCuvLHMg). This gave me the opportunity to talk about `elm-test` and to show the strengths of the Test Driven Development technique. 

Episode 7 [on Github](https://github.com/axelerator/elm-tetris/tree/episode7)
<iframe width="560" height="315" src="https://www.youtube.com/embed/ZXMQCuvLHMg" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

1. [Console logging in Elm](#debug)
2. [Installation und Verwendung von `elm-test`](#elm-test)
3. [Test Driven Development](#tdd)
4. [Wo war der Fehler in Episode 6?](#fail)

### <a name="debug" /> Console logging in Elm

I wasn't really fit when I recorded episode 6 and I introduced a logical error into the new code. I had different speculations about what the problem could be (all wrong) and tried to close in on the error using a lot of debug output.

Elm comes with a [`Debug` packet](https://package.elm-lang.org/packages/elm/core/latest/Debug). The [`log` function](https://package.elm-lang.org/packages/elm/core/latest/Debug#log) lets us print debug output to the JavaScript console, pretty much exactly like the [`console.log`in JavaScript](https://developer.mozilla.org/en-US/docs/Web/API/console/log).

At first sight however it looks a bit strange how it has to be invoked:

```Elm
sumIt : Int -> Int -> Int
sumIt a b =
  let
    _ = Debug.log "a is:" a
  in
    a + b
```

Why can't we just write `Debug.log "a is:" a` only? The reason is that the intention of the `let` block is to **give names** to expressions.
`Debug.log` is **the only** function in Elm that's not **pure** and where we don't care about its result.
**All other** we call **only** to get their result. So for our `Debug.log` line to have the same format as the other expressions in a `let` block, we'll just assign it the name `_` (the underscore).
By doing so it can be avoided that the compiler has to implement an extra syntax rule **only** for the `Debug.log` call.

This is not the only use case for the underscore. We use it generally as an identifier for an expression that is not used further down the function body.

I already did that in the [`mkEmptyRow` function](https://github.com/axelerator/elm-tetris/blob/episode5/src/Main.elm#L137):

```Elm
  mkEmptyRow _ =
      Row <| map (\_ -> Empty) (range 1 11)
``` 

I#m using the "looping notion" of the [`map` function](https://package.elm-lang.org/packages/elm/core/latest/List#map) to call another function on every element in a [range](https://package.elm-lang.org/packages/elm/core/latest/List#range) 
But in this function, I'm not really interested in the actual number for each iteration. By using the underscore as the identifier for the parameter we're giving a potential reader of the code an **early** sign that they don't have to care about it.

### <a name="elm-test" /> Installation and usage of `elm-test`

`elm-test` is a standalone tool that has to be installed separately next to the `elm` executable.
The execution of our Elm (test-) code is done with Node.js. So it's not surprising that it's installed with the `npm` packet manager, which goes hand in hand with Node.js.

So to be able to install `elm-test` one first has to install Node.js. Next to the [official download](https://nodejs.org/en/) there are a few different other ways to install it depending on the operating system as well.

I personally prefer [nodenv](https://github.com/nodenv/nodenv) to manage my Node.js installations, because it allows me to have multiple, different versions of it installed.

### <a name="tdd" />Test Driven Development

My failed attempt to "wing" the implementation of the collision detection turned into a welcomed opportunity to demonstrate the strengths of **Test Driven Development** (TDD).

TDD is not an Elm-specific technique. It's been around for more than 20 years! It was popularized by [Kent Beck](https://twitter.com/KentBeck) and is part of a larger methodology called [extreme programming](https://en.wikipedia.org/wiki/Extreme_programming).

In this technique, we start by writing a test first before we start writing the implementation. But why?

As a developer, it's easy to get too excited about the **solution**. As demonstrated in episode 6 it's very tempting to start writing the implementation first. Signatures and names of functions follow as a mere afterthought.

TDD forces us to think about the **what** before the **how**. Before we execute the test we have to make up our mind how we want to call the function. That usually leads to functions that are better named and easier to test.

TDD also means we start with the simplest, smallest most naive test. We then follow up with a constant alternation of:

- Making the test pass, by extending the implementation
- Adding another failing test, that tests for the smallest logical addition 

In episode 7 I start by reverting all changes from episode 6 to start from scratch. Over the duration of the episode, I create a full test suite just by following that technique. And it already pays off at the moment where I add some of the more complex logic in the second half of the episode.
Thanks to the tests that I had already written up to that point I was able to quickly identify the mistake without the need for adding excessive needs of logging.

### <a name="fail"/>Where was the mistake in episode 6?

I was pretty exhausted when I recorded the episode. But of course, I still had to figure out where I made the mistake! Did you find it?

The error was in the calculation of the positions that the dropped piece **would** have taken. The expression `translateTile` uses the **current** position of the piece instead of the one in the row below.

Wrong:
```Elm
  translateTile ( tx, ty ) =
      ( x + tx, y + ty )
```

Fixed:
```Elm
  translateTile ( tx, ty ) =
      ( x + tx, nextRow + ty )
```

On top of that, I added more mistakes in my attempt to fix it ( the `- 1` when dropping rows/columns). So while I was not super happy after recording the first attempt, I am happy that I went the extra mile with `elm-test`. This way I have a working test setup that's easy to extend for the upcoming tasks!




