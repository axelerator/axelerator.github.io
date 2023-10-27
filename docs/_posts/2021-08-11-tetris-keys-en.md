---
layout: post
title:  "Episode 5: Registering keystrokes"
date:   2021-08-13 15:00:00 -0400
ref: tetris-key-strokes
lang: en
permalink: /elm/en/tetris-key-strokes
tags: elm
---

In [this episode (40min)](https://www.youtube.com/watch?v=JG3zzF_jRVc&t=1013s) we investigate how to react to global keyboard events. Once more we're putting the "subscription system" to use which we got to know [last episode](/elm/en/tetris-gravity)

In today's show notes I'll revisit the following topics:

1. [Batching of multiple subscriptions](#subs)
2. [Why is parsing/decoding of JSON so complicated in Elm?](#parsing)
3. [How does our `keyDecoder` work?](#decoder)

<iframe width="560" height="315" src="https://www.youtube.com/embed/JG3zzF_jRVc" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

This episode is available on Github: [Branch Episode5](https://github.com/axelerator/elm-tetris/tree/episode5) [Commit](https://github.com/axelerator/elm-tetris/commit/ff76dcab313f67bd8e878857dfa8cd0af18e2c53)

### <a name="subs"/>Batching of subscriptions

The `subscriptions` are a core part of our application and we have to pass it as part of our "application root".

```Elm
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }

subscriptions : Model -> Sub Msg
subscriptions model = ..
``` 

The signature of `subscriptions` is very explicit about the fact, that it expects exactly **one** subscription.
However, we already registered one for the gravity timing function last time:

```Elm
subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every 1000 GravityTick
```

As demonstrated in the episode I can't just turn this expression into a list: `[Time.every 1000 GravityTick, onKeyDown keyDecoder]`.

This expression would have the type `List (Sub Msg)` and that is not compatible with the expected `Sub Msg`.

To solve this we can use the [`batch` Funktion](https://package.elm-lang.org/packages/elm/core/latest/Platform-Sub#batch).
With this function, we can *wrap* multiple subscriptions into a new one. One of those *batches* may contain more batches so that we can create arbitrary "thick" bundles of subscriptions.

The final solution in our case however is rather unspectacular and looks like this:

```Elm
subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Time.every 1000 GravityTick
        , onKeyDown keyDecoder
        ]
``` 

### <a name="parsing"/>Why is parsing/decoding of JSON so complicated in Elm?

As already mentioned in the video a complete explanation of JSON decoding warrants its own article. There is a [short introduction in the official guide](https://guide.elm-lang.org/effects/json.html).
But other people have already created exhaustive articles about the more complex cases that are not covered there. For example [this article on elmprogramming.com](https://elmprogramming.com/decoding-json-part-1.html#decoding-json).

Compared to other languages like JavaScript or Ruby it seems like decoding JSON in Elm is unnecessarily complicated. I fought with it for quite a while myself when I *'just wanted to read some JSON'* in Elm for the first time.
So today I'd like to convince you that it's not *that* complicated after all and that the additional complexity is well worth it.

At the end of the coding session we ended up with a JSON decoder that looked like this:

```Elm
keyDecoder : Decode.Decoder Msg
keyDecoder =
    Decode.map toKey (Decode.field "key" Decode.string)

toKey : String -> Msg
toKey string =
    case string of
        "ArrowLeft" ->
            KeyDown LeftArrow

        ... -> ...
```

The [`toKey`](https://github.com/axelerator/elm-tetris/blob/ff76dcab313f67bd8e878857dfa8cd0af18e2c53/src/Main.elm#L246) is trivial because it just converts a `String` into a `Msg`.

But the `keyDecoder` is a bit more feisty! As a first attempt to understand what it *means* let's take a look at the [official definition](https://package.elm-lang.org/packages/elm/json/latest/Json-Decode#Decoder) of what a `Decoder` is:

> `type Decoder a`<br />
> A value that knows how to decode JSON values.

And it sends us to the [official guide](https://guide.elm-lang.org/effects/json.html) for more details.
I don't want to reiterate what's written there but will try to give an alternative explanation.
I hope this will address some questions that people might have that come from 'a less functional' background.

The first confusing thing if we look at the definition of `keyDecoder` is that despite it's supposed to 'read' something from JSON it doesn't take an input parameter.
This is in line with the official statement that it's "a value that knows how to decode JSON". But how can this possibly work?

The missing link here is one of the core principles of functional programming: Functions are values too!
The [Decoder library](https://package.elm-lang.org/packages/elm/json/latest/Json-Decode) contains a handful of predefined primitive decoders (functions) that can be combined into more complex ones.

"But why doesn't the signature *look* like a function" you might ask. 
The [definition](https://package.elm-lang.org/packages/elm/json/latest/Json-Decode#Decoder) in the docs shows us only "the left" side of the type definition.
Such a type, where we don't know what the "right" side of the definition holds is called [an opaque type](https://en.wikipedia.org/wiki/Opaque_data_type).
It means the developer of this type doesn't **want** the caller to know how it is defined internally. But I'm pretty sure there is something in there that looks much more like a function!

At a glance, this might seem unnecessarily restrictive. But used well this concept is extremely **liberating**. As a user of the library, I don't need to know anything about the internal mechanics. And because I can't interact with them it's also impossible for me to use it wrong or break it (as long as it compiles).

To understand further how all of this is useful we'll look at an example of how such a decoder can be used outside our `onKeyDown` subscription context.

The following code shows an example where we try to decode a `Msg` from a JSON string with the help of our decoder. The central piece is the call to the [`Decode.decodeString` function](https://package.elm-lang.org/packages/elm/json/latest/Json-Decode#decodeString). It expects a `Decoder` and a `String` and tries to create a value of the target type from that.


```Elm
eventJsonToKeyMsg : Msg
eventJsonToKeyMsg jsonString =
    let
        jsonString =
            "{ \"key\" : \"ArrowLeft\"}"
        
        parseResult =
            Decode.decodeString keyDecoder jsonString
    in
    case parseResult of
        Ok msg ->
            msg
        Err e -> 
          let
            _ = Debug.log "invalid" (Decode.errorToString e)
          in
            Noop
```

The Elm JSON library is a good example of the ["separation of concerns" principle](https://en.wikipedia.org/wiki/Separation_of_concerns).

Our `keyDecoder` definition is decoupled from the actual parsing of the JSON. We don't have to worry about missing brackets and so on when defining where to look for certain pieces.
That alone however is not very impressive. After all we can parse a JSON String into an object with one instruction in most other languages as well. For example in JavaScript with the [`JSON.parse()` function](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/JSON/parse).
But what is also decoupled is the handling of errors when the JSON is syntactically correct but doesn't match the **structure** that our decoder specifies!

Let's modify the input string to contain a typo (`key -> keX`):

```Elm
  jsonString =
      "{ \"keX\" : \"ArrowLeft\"}"
```

If we call the `eventJsonToKeyMsg` now we will run into the `Err e -> ..` branch and see the following output in the JavaScript console:

```
invalid: "Problem with the given value:
  { \"keX\": \"ArrowLeft\" }
Expecting an OBJECT with a field named `key`"
```

So the Elm compiler not only uses the type system to think about the error case by return a value of the [type Result](https://package.elm-lang.org/packages/elm/core/latest/Result#Result).
It is also able to tell us exactly where our input JSON doesn't match the structure.

For small examples like ours, we're not profiting that much from all of this. In real life applications, especially when dealing with external APIs, we'll encounter much more complex structures. Being able to quickly find out structural mismatches when either we or the API provider changes something allows us to continue to evolve our application quickly.


### <a name="decoder"/>How does our `keyDecoder` work?

Ok, so we know now why decoders how they're defined by Elm make sense in the bigger picture. But in the video, I just copied over the definition [of our `keyDecoder`](https://github.com/axelerator/elm-tetris/blob/episode5/src/Main.elm#L241) without going into detail on how it exactly works.

To understand how it works it helps to break it up into these two functions. The result is functionally identical to the original definition.

```Elm
keyDecoder : Decode.Decoder Msg
keyDecoder = Decode.map toKey keyNameDecoder

keyNameDecoder : Decode.Decoder String
keyNameDecoder = Decode.field "key" Decode.string
```

The extracted helper function `keyNameDecoder` is now a decoder that wants to read a string value from a JSON object.
When executed it will look for a value that is stored for the field with the name `key`.
If it doesn't find it or it is not a string decoding will fail and return the `Err` variant of the `Result`.

The magic glue in the whole construct is the [`Decode.map` function](https://package.elm-lang.org/packages/elm/json/latest/Json-Decode#map)

```Elm
map : (a -> value) -> Decoder a -> Decoder value`
```

For better understanding, we'll replace the type parameters with the actual types of our example.


```Elm
map : (String -> Msg) -> Decoder String  -> Decoder Msg`
```

Written like this the signature reads like this:

`map` is a function that expects two parameters:
1. A function to turn a `String` into a `Msg`
2. A decoder that extracts a String from a JSON object
The result of `map` is a new decoder that will try to create a `Msg` value from a JSON object. 

The next question is of course how we can create values of types that require **more** than one parameter. For those cases, the library offers the `map2, map3, .., map8` functions.
The example in the [documentation of map2](https://package.elm-lang.org/packages/elm/json/latest/Json-Decode#map2) decodes a JSON into a `Point` value that has an `x` and a `y` property.

```Elm
type alias Point = { x : Float, y : Float }

point : Decoder Point
point =
  map2 Point
    (field "x" float)
    (field "y" float)
```

Adding and removing properties from types requires us to also always update the  `mapX` call. The external [`elm-json-decode-pipeline` library](https://package.elm-lang.org/packages/NoRedInk/elm-json-decode-pipeline/latest) offers alternative combinators to express more complex decoders more elegantly.
