---
layout: post
title:  "Episode 11: Game Over"
date:   2021-09-23 18:00:00 -0400
ref: tetris-game-over
lang: en
permalink: /elm/en/tetris-game-over
---

<img src="/assets/posts/tetris-game-over/game-over.gif" style="float:right; margin: 5px 10px 10px 0"/>
There are still a few elements missing to be able to call our Tetris complete. However, with the changes from [episode 11 (40min)](https://youtu.be/To2MtBs3w6A) we're at least able to tell the player *"Game Over"*.

The last [commit](https://github.com/axelerator/elm-tetris/commit/8838b88b82af29c95ac3a0bfafe17eba27b254b9) on the [episode11 branch](https://github.com/axelerator/elm-tetris/tree/episode11) reflects the changes I made during the recording.

<iframe width="560" height="315" src="https://www.youtube.com/embed/To2MtBs3w6A" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

This time I didn't really use any new, fancy concepts. But this is another feature that differentiates *Elm* from many other programming languages. The Syntax is comparatively simple. In other languages, like *Ruby* or *Python* for example, we find syntax elements for many dogmas (object oriented *and* functional).
As a result, there are naturally multiple ways to approach a problem, none of which is necessarily more dogmatic to the language than the other.
The fact that Elm is dedicated to the *functional* approach **only** leads to fewer diverging ways to solve a particular problem. This leaders to more unified code which helps to understand code that I've not written myself faster. And conversely also to write code that **other people** understand faster.

Of course, there is still enough room to express things a bit differently, even in Elm. A tool that I often only think of on the second attempt is **pattern matching**. But I did manage to think of it for this week's changes eventually.

The most important change however was the *'upgrade'* of our central `Model` type from an *alias* to an *algebraic data type*.


*before*:
```Elm
type alias Model =
  { board : Board
  , currentPiece : Maybe CurrentPiece
  }
```

*after*:
```Elm
type Model =
    = RunningGame GameDetails
    | GameOver Board
```

Even though the *"content"* of the two variants is nearly the same it pays off to introduce a clear distinction between the two game states **now**. A variety of operations doesn't make sense to apply when the game has ended.
By expressing that state in its own proper variant we can let the compiler direct us to the places in the code where we should check if the logic still adds up for our new case.

One central place for that is the `update` function. As mentioned in the stream I learned the following trick from [Richard Feldman](https://twitter.com/rtfeldman). He maintains the [*Elm SPA example*](https://github.com/rtfeldman/elm-spa-example), a fully-fledged fullstack application built with Elm, which contains lots of useful patterns on how to deal with real-world problems.


I changed our `update` function from

```Elm
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    GravityTick _ ->
      dropCurrentPiece model
```

to look like this (abbreviated):
```Elm
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case ( msg, model ) of
    ( GravityTick _, RunningGame gameDetails ) ->
      dropCurrentPiece gameDetails
```

By extending the expression between `case ... of` to a **tuple** of `msg` **and** `model` we can now also match on the state of our model.
We also add a "fallthrough" branch that gets matched for all the combinations we didn't explicitly name.
That has the pleasant effect that we **don't** need to specify the combinations that don't make sense, for example `(KeyDown key, GameOver)`

That means in the end we need *less code*, which is usually desirable. But it also comes with one drawback. We lose the luxury of the compiler being able to point us to the `update` function whenever we add a new variant to our `Msg` type. In the edited version of our `update` function we now have the `_ -> ...` branch that will also match any new variant we match.
So in the end one has to balance what's more important on a case-by-case basis.

- How many cases do I have to be explicit if I don't want to add the fall through?
- How easy is it to find out where I need to extend case expressions if I add a new variant?

