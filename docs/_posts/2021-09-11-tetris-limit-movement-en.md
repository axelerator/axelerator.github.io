---
layout: post
title:  "Episode 9: Preventing invalid movements"
date:   2021-09-11 16:00:00 -0400
ref: tetris-limit-movement
lang: en
permalink: /elm/en/tetris-limit-movement
tags: elm
---

In [episode 9 (48min)](https://www.youtube.com/watch?v=ZacgfAavKzQ) I make sure the current piece can't be moved out of the board or into other pieces. With that came the opportunity to do a little functional finger exercise and develop a function that swaps the arguments of another function.



The state of the code can be found on the [episode9 branch](https://github.com/axelerator/elm-tetris/tree/episode9).
Or you can have a look at the [commit](https://github.com/axelerator/elm-tetris/commit/c9e1d2564626e3584e96500ee210ad14a7a9b1c4) if you just want to see what's changed.


<iframe width="560" height="315" src="https://www.youtube.com/embed/ZacgfAavKzQ" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

1. [Movement allowed?](#canmove)
2. [Excursion *Currying*](#curry)

### <a name="canmove" /> Movement allowed?



The entry point for this week's changes was the [`movePiece` function](https://github.com/axelerator/elm-tetris/blob/episode8/src/Main.elm#L222). The goal was to extend the logic in a way that would prevent invalid moves.

With nearly 50 lines of code, the `movePiece` function was already quite long, to begin with. But with the application of a few basic syntax elements, we were able to keep the length at that despite adding the new logic.

The definition of what I understand to constitute a valid move is as follows:

> All fields the current piece **would** occupy on the board must be empty.
> If that's not the case, don't execute the move

The significant change of the code looks like this:

```Elm
movePiece : Key -> Model -> Model
movePiece key model =
  ...
  let
      canMove =
          all ((==) (Just Empty)) <|
              map (flip lookUp model.board) <|
                  occupiedPositions movedPiece
  in
  if canMove then
      { model | currentPiece = Just movedPiece }

  else
      model
```

One sign of high software quality is in my opinion when the 'natural mental model' can be read directly from the code
From my point of view Elm offers many ways to combine expressions in a way that brings us close to this goal.

If we read the calculation of `canMove` from the bottom up, `canMove` is true if:

- the positions the current piece would occupy (`occupiedPositions movedPiece`)
- transformed into the state of the field on the board (`map (flip lookUp model.board)`)
- are all empty (`all ((==) (Just Empty))`)

### <a name="curry" /> Excursion *Currying*

I discovered functional programming thanks to my professor [Uwe Schmidt](https://github.com/UweSchmidt) at university.
But the theoretical groundwork for it only partly managed to persist in my brain. What led to me fumbling a bit for words when it came to explain what concepts I was making use of when I developed the [`flip` function](https://github.com/axelerator/elm-tetris/blob/episode9/src/Main.elm#L250)

That's why I'd like to spend a few lines here to make up for the lack of explanation. In the [previous episodes](https://blog.axelerator.de/elm/en/board) I made use of partial function application quite a bit.

*Currying* describes a process to transform a function in a way that **every** parameter can be called/bound separately. In some languages like Elm and Haskell functions are automatically curried.

But currying is also possible in languages that don't have it build in, for example in JavaScript
However, we do have to explicitly rewrite our function definition and how we call the function.

```Javascript
// not curried
function addAndMultiply(a, b, times) {
  return (a + b) * times;
}

// curried
function addAndMultiplyCurried(a) {
  return function(b) {
    return function(times) {
      return (a + b) * times;
    }
  }
}

// curried ES6
const addAndMultiplyCurriedES6 = 
  (a) => 
    (b) => 
      (times) => (a + b) * times;

// same result
addAndMultiply(1,2,3) == addAndMultiplyCurried(1)(2)(3)
```

Functions that are *curried* are more versatile. That is mainly for their ability to use them with partial function application, of which we made use multiple times already in our little Tetris program.

The use of currying alone does not make a program automatically X% better. I would even argue that in languages that require an extra effort to rewrite a function it's not worth it.
However in languages where it comes for free out of the box, it quickly becomes a tool you don't want to miss. And the larger a software project grows the more even those little optimization pay off.

One 'fun fact' one must mention when talking about *currying* is how it's got its name. It's based on the work of [Haskell Curry](https://en.wikipedia.org/wiki/Haskell_Curry). An American logician who took great inspiration from [Moses Schönfinkel](https://en.wikipedia.org/wiki/Moses_Sch%C3%B6nfinkel)s concept of [combinatory logic](https://en.wikipedia.org/wiki/Combinatory_logic). So strictly speaking it should be called *schönfinkeling* - but that just does not roll off the tongue as easily I guess.

