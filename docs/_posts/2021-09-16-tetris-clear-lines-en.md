---
layout: post
title:  "Episode 10: Clearing lines"
date:   2021-09-16 19:00:00 -0400
ref: tetris-clear-rows
lang: en
permalink: /elm/en/tetris-clear-rows
---

<img src="/assets/posts/tetris-clear-rows/teaser.gif" style="float:left; margin: 5px 10px 10px 0"/>
Damit mein Tetris spielbar wird sorge ich in  
dafür, dass vollständige Zeilen verschwinden. Mit mehr Unit-Tests und der Anwendung der Faltung einer Liste nähere ich mich einem vollständigen Version.

For my Tetris to be actually playable I'm adding in [episode 10 (55min)](https://www.youtube.com/watch?v=b1vnT6XTFP4) the code to have full rows cleared. With the help of more unit tests and the infamous `fold` function, I'm inching my way towards a complete solution.


The state of the code after this episode is captured in the [episode10 Branch](https://github.com/axelerator/elm-tetris/tree/episode10). The changes I made can be found in the last [Commit](https://github.com/axelerator/elm-tetris/commit/74ac057b1037e10cd6c47b63647952c943054718).

<iframe width="560" height="315" src="https://www.youtube.com/embed/b1vnT6XTFP4" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

It's always satisfying when you lay out a plan and the implementation actually adheres to it. That's why recording this episode was extra fun. Of course, developing (at least partially) *test-driven* helped with that.

The initial idea was to come up with an `eraseCompleteRows` function that takes a board and returns a new one where the *complete* rows have been removed

It was easy to start by writing a test since I had already set up unit tests in [Episode 7](/elm/en/tetris-collision).



The algorithm I wanted to implement has the following steps.

1. Run through all rows of the board and for each:
 - *1a* for an **incomplete** row: collect it as a  *"bottom"*-row for the resulting board
 - *1b* for a **complete** row: add an **empty** row in a new list of *"header"*-rows 

2. Create the result by *appending* the empty "header" (1b) rows on top of the incomplete "bottom" (1a) rows

For the implementation, I went with the [foldr](https://package.elm-lang.org/packages/elm/core/latest/List#foldr) function. Since a few people seem to be a bit anxious when it comes to folding I want to use the first application of in in my Tetris as an opportunity to go a bit into detail about how it works.


### What is `foldr` good for?

`foldr` exists in many languages, but is sometimes referred to under a different name:

- [reduce](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/Reduce) in JavaScript
- [inject](https://ruby-doc.org/core-3.0.2/Enumerable.html#method-i-inject) in Ruby

Similarly to `map` we pass it a function that's executed for every element in a collection (that we also have to pass).
Contrary to `map` though the result doesn't *have* to be a list of the same length. It can be of an arbitrary type.
In that sense, it's more flexible or powerful.

On the flip side, we're buying this extra flexibility with a tad more complexity. That becomes obvious if we compare the signatures of `map` vs. `foldr`.


```Elm
map :   (a -> b)             -> List a -> List b

foldr : (a -> b -> b)  ->  b -> List a -> b
```

`map` is relatively simple: It transforms a list of items of type `a` into a list of elements of type `b`.
Just by calling the "transformer" function `(a -> b)` for each element.

I aligned the types of the different parameters to emphasize the differences between the two.
For `fold` the `b` type occurs a lot more often now!
And the *return type* is now **just** `b` instead of `List b` as for `map`.

What was a simple `(a -> b)` transformer function for map has now become an `(a -> b -> b)`. That means the function that gets called *per Element* now **also** needs a value of the same type as the result of the whole operation.

And then there is the new `b` parameter in the middle. The second parameter we have to pass to `foldr` before we can pass it the list.

Let's look at a simpler application to understand better how these parameters work together.
Imagine we want to create a function `totalLength` that gives us the total number of characters for a given list of words.

```Elm
totalLength : List String -> Int
``` 

An imperative solution in JavaScript with a [`for` loop](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/for...in) could look like this.

```JavaScript
function totalLength(words) {
  var sum = 0;
  for (let word of words) {
    sum = sum + word.length
  }
  return sum;
}

totalLength(['x', 'yy', 'zzz']) == 6 // true
```

Such a solution is not possible in Elm. We can't **reassign** variables, so the whole construct of such a `for` loop doesn't make sense, and consequently, there is not even syntax for it in Elm.
But we have `foldr`, that gets the job **at least** as well done as a `for` loop.

To understand how to use `foldr` we will progressively *functionalize* our JavaScript solution.


Refactoring 1:

```JavaScript
function totalLength2(words) {
  var init = 0;
  var adder = 
    function(word, accu) { 
      return accu + word.length; 
    }

  var sum = init;
  for (let word of words) {
    sum = adder(word, sum);
  }
  return sum;
}
```
This does still the same as our initial implementation. And so will the next one.

Refactoring 2:

```JavaScript
function fold(f, init, array) {
  var sum = init;
  for (let item of array) {
    sum = f(item, sum);
  }
  return sum;
}

function totalLength3(words) {
  var init = 0;
  var adder = 
    function(word, accu) { 
      return accu + word.length; 
    }
  return fold(adder, init, words);
}
```

Now we have our own 'fold' implementation in JavaScript. And the way we call it is exactly the same way we use the `foldr` function in Elm.

```Elm
totalLength : List String -> Int
totalLength words =
  let
    init = 0
    adder word accu =
      accu + (String.length word)
  in
    List.foldr adder init words
```

## Application of `foldr` in `eraseCompleteRows`

The function is called `fold` or `reduce` because its application often takes a potentially long list and transforms it into a *single, small* value.

In the end, how small the resulting value is, depends primarly on the function we're *folding with*.

The [application of `foldr` in `eraseCompleteRows`](https://github.com/axelerator/elm-tetris/blob/74ac057b1037e10cd6c47b63647952c943054718/src/Main.elm#L396) creates a `Tuple` or pair where each element is a list of rows.

That's the case because the function *we're folding with* has this return type.

```Elm
folder : Row -> ( List Row, List Row ) -> ( List Row, List Row )
folder ((Row fields) as row) ( nonEmptyRows, header ) =
    if isFull row then
        ( nonEmptyRows
        , mkEmptyRow (length fields) 0 :: header
        )

    else
        ( row :: nonEmptyRows
        , header
        )

( allNonEmptyRows, finalHeader ) =
    foldr folder ( [], [] ) board.rows
```

If we evaluate the type parameters of our `foldr` call we get the following picture.
I start by defining a little type alias to keep the listing more concise

```Elm
type alias RowTuple = (List Row, List Row)

foldr : ( a   ->    b    ->     b   )  ->   b  -> List  a  ->    b
foldr : (Row -> RowTuple -> RowTuple)  ->  RowTuple -> List Row -> RowTuple
``` 

The *second* parameter for `foldr` is the `b` our "folder" gets passed in for the call with the first `Row`.
Every following call to `folder` gets the **return** value of the previous call as its `b` parameter.


The first time our `folder` function gets called:

```Elm
folder : Row -> ( List Row, List Row ) -> ( List Row, List Row )
folder row ( nonEmptyRows, header ) = ..
```

`row` will contain the first row and `( nonEmptyRows, header )` will have the value `([], [])`. Because the latter is the **second parameter** of our call:  `foldr folder ( [], [] ) board.rows`

- is the row **complete** we'll append **an empty** row to the **second** list in the tuple
- is the row **incomplete**  we'll append **that row** to the **first** list in the tuple

This process is repeated until for each row we either 'kept' the row in the first list or appended an empty one in the second.

After that we end up with two lists:

- all the incomplete rows we kept, which will go on the bottom of the new board
- a list of empty rows to compensate for the complete ones we want to remove

Now we just have to concatenate those two lists in the right order to assemble the board in the expected state.

<img src="/assets/posts/tetris-clear-rows/fold.svg" style="width: 100%"/>
