---
layout: post
title:  "Episode 2: Rendering the empty board and partial function application"
date:   2021-07-07 20:00:00 -0400
ref: basic-board
lang: en
permalink: /elm/en/board
---

After we looked at the structure of an Elm app line by line last week, we had a more abstract look at the mechanics of an Elm app today. But after that we jumped right into the code that would render the empty Tetris board.

[<img src="/assets/posts/basic-board/architecture.png" width="300" />](/assets/posts/basic-board/architecture.png)

The state of the code at the end of the episode is available on the [episode2 branch on Github](https://github.com/axelerator/elm-tetris/tree/episode2)

<iframe width="560" height="315" src="https://www.youtube.com/embed/rJXE328qYz8" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>


The development of an Elm application starts most of the time with thoughts about the central data types. That does not mean we have to know **all** the types and definitions from the begining though. We start with a very limited model that only contains what's necessary for our first goal: A board of empty rows. I have high confidence that the strong type system of Elm will support me to quickly develop the data model without introducing regressions.

There was one aspect that we looked at that I'd like to give a bit more context on. The way function are declared in Elm might seem a bit alien to users of more classic programming languages.

```Elm
fieldView : Int -> Int -> Html Msg
fieldView row column =
  rect [x (col * 10), y (row * 10)] []
```

The first row is the signature of the function and it can be read like this:

> `fieldView` is a function with two parameters of type `Int`
> and it returns a value of type `Html Msg` .

## "But why are the parameter Types not enclosed in paranthesis like in a normal language?"
The reason for that is, that this is not the only way the signature can be interpreted!
You could also read it like this:


> `fieldView` is a function that recieves **one** `Int` parameter.
> The return value is a (new) **function** that recieves one (the other) parameter of type `Int`
> and returns an `Html Msg`.

Pratically speaking that means `fieldView` will return **either** an `Html` value **or** a function depending on with how many parameters we call it.

## "But what is that good for!?"

Using this principle is called *partial application*. And it only really shows its strength when we use it in combination with functions that expect other functions as parameter.

The most prominent example from this family of function is [map](https://package.elm-lang.org/packages/elm/core/latest/Array#map).
It applies a given function to each element in a list.

A simplified version of the function that renders the board looks like this:

```Elm
boardView : Html Msg
boardView =
  let
    rowNumbers = range 0 20
  in
    map rowView rowNumbers

rowView : Int -> Html Msg
rowView rowNumber =
  let
    columnNumbers = range 0 10
  in
    map fieldView columnNumbers

fieldView : Int -> Int -> Html Msg
fieldView row column =
  rect [x (col * 10), y (row * 10)] []
```

This code will actually not compile, because the return value of `rowView` doesn't match with what we've declared.
We're calling `map` with `fieldView`. A function that will return another function when we call it with **one** `Int`.
But we need to get an `Html` back!. The solution is to *"bake in"* the rowNumber into `fieldView` and create a new function that only expects the columnNumber.

A very verbose way to do this could look like this:

```Elm
-- takes *one* Int
-- returns a function that turns another Int into Html 
fieldInRow : Int -> (Int -> Html Msg)
fieldInRow rowNumber = fieldView rowNumber -- this is partial application 

rowView : Int -> Html Msg
rowView rowNumber =
  let
    columnNumbers = range 0 10
  in
    map (fieldInRow rowNumber) columnNumbers
```

And now comes the ![mind blown](/assets/mindblown.gif) moment.
If we remove the paranthesis in the definition of  `fieldInRow : Int -> (Int -> Html Msg)` we see it is exactly the same as
the defintion of `fieldView : Int -> Int -> Html Msg`.

And the functionality is also exactly the same. That's why we can just leave the whole function `fieldInRow` away.

```Elm
rowView : Int -> Html Msg
rowView rowNumber =
  let
    columnNumbers = range 0 10
  in
    map (fieldView rowNumber) columnNumbers
```

That's the power and beauty of partial function application!
