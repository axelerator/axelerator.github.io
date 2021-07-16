---
layout: post
title:  "Episode 3: Definition, Rendering of Tetris pieces and static typing"
date:   2021-07-16 16:00:00 -0400
ref: tetris-pieces
lang: en
permalink: /elm/en/tetris-pieces
---

This week I developed the data structures that are necessary to define and render the characteristic Tetris pieces. I was a bit surprised it took me more than 1.5 hours, but I never was the fastest 😅.

View this episodes code on Github: [Branch](https://github.com/axelerator/elm-tetris/tree/episode3) [Commit](https://github.com/axelerator/elm-tetris/commit/89196d6adb25f4edadea7aac9af5b865094ea256)

In this article:

 - [What is an algebraic data type?](#adt)
 - [What's all the fuzz about with types?](#statictyping)
 - [Automatic exhaustiveness checking](#exhaustiveness_check)
 - [Pattern matching](#patternmatching)

<iframe width="560" height="315" src="https://www.youtube.com/embed/JhIVeAYEXZU" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

For this post I want to shine the light on [algebraic data types](https://en.wikipedia.org/wiki/Algebraic_data_type) and the general benefits of static typing.


## <a name="adt">What is an algebraic data type?</a>

This term sounds very fancy and complicated, but they're a very handy tool I miss in a lot of other programming languages. And I hope by looking at a few examples of the Tetris project I can show that they're not that complicated after all.

Algebraic data types (ADT) are also sometimes called *sum types*. The understanding here is that such a types represents the sum or union of all possible variants it declares.
A simple example for such a type is our type `FieldColor`:


```Elm
type FieldColor = Blue | Red
```

With this we're declaring a new *type* with the name `FieldColor`. A value of this type can be either a `Blue` **or** a `Red`.

Hier are two example expressions/values of this type:


```Elm

iAmRed : FieldColor
iAmRed = Red

iAmNotRed : FieldColor
iAmNotRed = Blue
```

It's noteworthy that the only type we added is `FieldColor`. `Blue` and `Red` are variants and can not be used as Type. If we try to use `Blue` in a signature as type we'll get the following error:


```Elm
iDontCompile : Blue
iDontCompile =
    Blue

Detected problems in 1 module.
-- NAMING ERROR --------------------------------------------------- src/Main.elm

I cannot find a `Blue` type:

1| iDontCompile : Blue

```

A different way to think about ADT is the parallel to the relationship between subclasses in an object oriented model. The type is to its variants what an abstract base class is to its concrete subclasses (ignoring the fact that subclasses are types).

That also helps to extend the understanding to variants with data fields. As an example we can look at the `Field` data type we introduced this episode:


```Elm
type Field = Empty | Field FieldColor

iAmARedField : Field
iAmARedField = Field Red
```

So in Java this could look like the following snippet:


```java
abstract class AField {}

class Empty extends AField {}

class Field extends AField {

  FieldColor fieldColor;

  public Field(FieldColor fieldColor) {
    this.fieldColor = fieldColor;
  }
}

AField iAmARedField = new Field(new Red());
```

Because we use the names on the right side of our Elm type definition to construct new values by passing in the data fields we also call them *constructor functions*.

The two examples show vividly how much more expressive the Elm syntax is. The fact that they mean pretty much the same but the Elm code is much shorter results in the fact that we can express more per character/line in Elm than in Java.

Of course *less* is not always more when it comes to code. But in this example the extra length stems from long keywords and parenthesis structures without adding meaning.

## <a name="statictyping">What's all the fuzz about with types?</a>

Generally types are used to transport *meaning*. They primarily help the developer (not the computer) to understand the code. As a proof you can actually remove all type declarations from the Tetris program: It will still compile and run!

It's already the types in a signature that'll help the reader to understand the *intention* of a function.

```Elm
setField : Position -> FieldColor -> Board -> Board
```

This is an underrated software quality.

Dies ist eine häufig unterschätze Softwarequalität. Code wird nur einmal geschrieben. 

> Code is only written once.
> But software is getting extended constantly and has to be read and understood over and over again.

Now one could argue that well chosen names for the parameters have a similar effect. A Ruby method could for example look like this:


```Ruby
class Board
  def set_field(position, fieldColor)
    ...
  end
end
```

And it is true, that we can derive the intention nearly as well (what is going to be returned?) as in the Elm example.
But by using the type in combination with the compiler we get another benefit! In the case we call the function a the wrong way the compiler is able to give us very concrete what we're doing wrong


```
The 2nd argument to `setField` is not what I expect:
1|  board = setField ( 5, 3 ) "red"  Blue emptyBoard }
                              ^^^^^
This argument is a string of type:
    String.String

But `setField` needs the 2nd argument to be:
    FieldColor
```

This feature is completely absent in dynamically typed languages. Nobody stops me from calling a function with parameters of completely nonsensical types.
In critical software we'll try to avoid running into bugs caused by this by writing exhaustive test suites.
In practice this leads to large software projects having enormous amounts of tests that take a long time to run. Another negative aspect of having these large number of tests is that for large refactorings we also need to adapt a high number of tests.
A lot of them tests that we don't have to write in the first place if we use a statically typed language.



## <a name="exhaustiveness_check">Automatic exhaustiveness checking</a>

In contrast to the class example in Java we can't extend the number of variants once a type is defined. But this limitation comes with a great benefit. Since the compiler knows all the variants it can check for all function that consume such a value if all variants were handled.

Let's look for example at the function that calculates the web color name for one of our fields:

```Elm
ffToColor : Field -> String
ffToColor field =
    case field of
        Empty ->
            "gray"

        Field Blue ->
            "blue"

        Field Red ->
            "red"
```

In the case we extend our type declaration to include the additional value `Green`


```Elm
type FieldColor = Blue | Red | Green
```

the missing handling of the `Green` variant will be pointed out to us the next time we try to compile the code:

```
This `case` does not have branches for all possibilities:
269|>    case field of
270|>        Empty ->
271|>            "gray"
272|>
273|>        Field Blue ->
274|>            "blue"
275|>
276|>        Field Red ->
277|>            "red"

Missing possibilities include:
    Field Green
```

We neither have to write runtime checks, nor write unit test nor use external tools like a [linter](https://en.wikipedia.org/wiki/Lint_(software)).


## <a name="patternmatching">Pattern Matching</a>

In the above example we're already making use of [*pattern matching*](https://guide.elm-lang.org/types/pattern_matching.html).

Technically our `Field` type has only two variants. But Elm lets us specify aka *match* the "data part" as well. Instead of only being able to match on the type or one specific value we can define on how much of the content of the expression we want to match.

For example we could also match less precisely like and delegate the "deeper" matching to a second function:

```Elm
ffToColor : Field -> String
ffToColor field =
    case field of
        Empty ->
            "gray"

        Field color ->
            colorToString color

colorToString : FieldColor -> String
colorToString field =
    case field of
        Red ->
            "red"

        Blue ->
            "blue"
```

Non of the solutions is inherently better or worse. The computer most certainly doesn't care. Ultimately it's an assessment to optimise for *cohesions* or agains *coupling*. Or the question what's more important to me: "Having everything in one place" or "Having one function doing exactly one thing".

The important thing here is that Elm gives us a lot of flexibility, and it is up to the developer to choose what leads to the most readable code. We can decide when to match on a compound value or when to destructure into more granular expressions.

For more examples how expressions can be matched aka destructured check out this [extensive cheat] sheet(https://gist.github.com/yang-wei/4f563fbf81ff843e8b1e)
