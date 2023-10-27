---
layout: post
title:  "Episode 4: Gravitation des aktuellen Steins mit Subscriptions"
date:   2021-07-24 11:30:00 -0400
ref: tetris-gravity
lang: de
permalink: /elm/de/tetris-gravity
tags: elm
---

Nach der Mammutepisode letzte Woche habe ich es diese Woche bei verdaulichen 30 Minuten belassen.

Das Ziel war es den aktuellen Stein 'fallen zu lassen'. Dafür habe ich eine neue Eigenschaft dem `Model` unserer Anwendung hinzugefügt die unter anderem die Position des Steins vorhält.

Aber der interessantere Teil ist, dass wir das ['Subscription'](https://guide.elm-lang.org/effects/) System von Elm nutzen um diese Position im Sekundenintervall zu aktualisieren.

Den Code von dieser Episode gibt es auf Github: [Branch Episode4](https://github.com/axelerator/elm-tetris/tree/episode4) [Commit](https://github.com/axelerator/elm-tetris/commit/d1b908b4f0dee9e4b58b1e3e4c48c6bdc2b45465)


<iframe width="560" height="315" src="https://www.youtube.com/embed/ZzvUUi4Hv04" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>


Um ein Ereignis jede Sekunde automatisch auslösen zu können müssen wir verstehen was **Subscriptions** in Elm bedeuten. Sie sind Teil der Definition unserer Andwendungsdefintion. Bisher waren sie leer (`Sub.none`) und wir brauchten uns nicht um sie zu kümmern.

```Elm
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
```

Um zu verstehen warum wir *Subscriptions* brauchen und wie sie mit den uns bekannten Elementen zusammenspielen schauen wir uns zunächst noch einmal die  Hauptschleife an.

![Elm application loop](/assets/posts/tetris-gravity/elmloop.svg)

1. Die Anwendung started mit dem `Model` Zustand den wir ihr mit der `init` Funktion übergeben.
2. Die `view` Funktion wird aufgerufen um den initialen Html Baum zu erzeugen.
3. Interaktive Elemente können Nachrichten vom Typ `Msg` generieren
4. Wenn ein `Msg` generiert wird, wird die von uns definierte `update` Funktion verwendet um den neuen `Model` Zustand zu berechnen.
5. `GOTO 2.`

Das schöne an diesem Modell ist, dass es genau einen Ort gibt an dem wir den Anwendungszustand verändern/berechnen.
Diese Tatsache macht es sehr einfach verschiedene Elm Anwendungen zu verstehen und zu erweitern. Das Modell ist sehr viel restriktiver als native JavaScript-Anwendungen die keinerlei Beschränkungen haben wer wann wo in welche Variablen schreibt.

Aber kann man mit einem solch restriktiven Modell trotzdem jeden Anwendungsfall abbilden?
Ein Fall der sich mit dem bisher präsentierten `init->view->update` nicht abbilden lässt ist das Problem dem wir uns jetzt widmen wollen:

> Jede Sekunde soll die Position unseres aktuellen Steins um eine Zeile verringert werden

In nativen JavaScript würden wir hierfür die [`setInterval` Funktion](https://developer.mozilla.org/en-US/docs/Web/API/WindowOrWorkerGlobalScope/setInterval#example_1_basic_syntax) nutzen die uns vom Browser zur Verfügung gestellt wird.

Aber in Elm haben wir keine Möglichkeit direkt JavaScript-Funktionen aufzurufen. Ein Grund dafür ist, dass es unser schön einfaches Dogma brechen würde, dass wir den Anwendungszustand lediglich von einem Ort (`update`) beeinflussen.

Um diesen Prinzip treu zu bleiben müssen wir also einen neuen "Fall" für unsere `update` Funktion einführen. Wir erweitern unseren 'Nachrichtentyp' `Msg` um eine neue Variante `GravityTick` und behandeln diese in der `update` Funktion. Dort rufen wir `dropCurrentPiece` auf die anhand des vorherigen Models eine neues Model mit der aktualisierten Position des aktuellen Steins berechnet.

```Elm
type Msg = ... | GravityTick 


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GravityTick ->
            ( dropCurrentPiece model
            , Cmd.none
            )

dropCurrentPiece : Model -> Model
dropCurrentPiece model = ...
```

So weit so gut. Doch wie **produzieren** wir diese neue Nachricht? Bisher haben wir lediglich mit interaktiven Elementen wie `<button>` Nachrichten gesendet.

Das ist der Moment wo **Subscriptions** ins Spiel kommen. Mit der `subscriptions` Funktion die wir als Teil unser Anwendungsdefinition übergeben können wir Quellen für Nachrichten registrieren die **nicht** durch den Benutzer ausgelöst werden!

```Elm
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }

subscriptions : Model -> Sub Msg
subscriptions _ =
    Time.every 1000 GravityTick
```

![Elm application loop](/assets/posts/tetris-gravity/elmloopsubs.svg)

Mit der [`every` Funktion](https://package.elm-lang.org/packages/elm/time/latest/Time#every) die uns von Elm zur Verfügung gestellt wird können wir eine solche Quelle registrieren.

`Time.every` wird aufgerufen mit einer Anzahl Millisekunden die definiert wie *häufig* die Nachricht gesendet werden soll. Als zweiter Parameter müssen wir spezifizieren *welche* Nachricht gesendet werden soll.

Die Signatur für `every` sieht etwas zu kompliziert aus für das, was ich gerade beschrieben habe:

```Elm
every : Float -> (Posix -> msg) -> Sub msg
```

Der zweite Parameter ist vom Typ `(Posix -> msg)` - das ist nicht wie ich beschrieben habe einfach eine Nachricht!
Das stimmt, und der Grund dafür ist, dass `every` unsere Nachricht `GravityTick` noch ein Stück Information mitgeben möchte: die aktuelle, absolute Zeit.
Der Grund dafür ist, dass uns der Browser nicht garantieren kann, dass die Nachricht tatsächlich exakt jede Sekunde gesendet wird. D.h. wenn wir zum Beispiel zählen wollen wieviel Zeit tatsächlich vergangen ist, sollten wir relativ von einer Uhrzeit rechnen als Sekunden zählen.

Damit `every` also eine Nachricht senden kann, die die aktuelle Uhrzeit enthält müssen wir ihr eine Funktion geben die eine Uhrzeit (`Posix`) erwartet und eine Nachricht erzeugt. 

Wenn wir unsere `Msg` Variante mit `Posix` als Parameter definieren hat der Name der Variante genau diese Signatur. Das ist der Grund warum wir einfach `Time.every 1000 GravityTick` schreiben können.


```Elm
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }

type Msg = .. | .. | GravityTick Posix | ..

subscriptions : Model -> Sub Msg
subscriptions _ =
    Time.every 1000 GravityTick

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GravityTick currentTime ->
            ( computeNewModel currentTime
            , Cmd.none
            )
        ...
```

Für unser Tetris interessiert uns nicht wirklich wieviel Zeit vergangen ist, sondern lediglich, dass etwas jede Sekunde passiert. Deswegen ignorieren wir die übergebene Zeit.
