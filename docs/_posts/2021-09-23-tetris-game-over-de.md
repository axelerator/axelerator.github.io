---
layout: post
title:  "Episode 11: Game Over"
date:   2021-09-23 18:00:00 -0400
ref: tetris-game-over
lang: de
permalink: /elm/de/tetris-game-over
tags: elm
---

<img src="/assets/posts/tetris-game-over/game-over.gif" style="float:right; margin: 5px 10px 10px 0"/>
Noch fehlen ein paar Elemente damit unser Tetris 'vollständig' ist. Aber zumindest können wir nach [Episode 11 (40min)](https://youtu.be/To2MtBs3w6A) sagen "Game Over".

Die Code-Änderungen von dieser Woche gibt es im [episode11 Branch](https://github.com/axelerator/elm-tetris/tree/episode11) bzw [Commit](https://github.com/axelerator/elm-tetris/commit/8838b88b82af29c95ac3a0bfafe17eba27b254b9).

<iframe width="560" height="315" src="https://www.youtube.com/embed/To2MtBs3w6A" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>



Diese Woche habe ich keine großartig neuen Konzepte genutzt. Aber gerade das ist etwas wo sich *Elm* von vielen anderen Sprachen abgrenzt. Die Syntax ist verhältnismäßig übersichtlich. In anderen Sprachen wie Ruby oder Python finden wir mehrere Dogmen (objektorientiert und funktional). 
Daher ergeben sich auch mehrere Ansätze ein Problem zu lösen von denen nicht unbedingt einer mehr oder weniger den Prinipien der Sprache entsprechen muss. Der ganzheitlich funktionale Ansatz von Elm führt zu einheitlicheren Lösungen. Das hilft es schneller Code zu verstehen, den man nicht selber geschrieben hat. Und natürlich auch selber besser verständlichen Code zu schreiben.

Dennoch gibt es natürlich auch innerhalb der Syntax noch genügend unterschiedliche Möglichkeiten sich auszudrücken. Ein Werkzeug an das ich häufig erst im zweiten Durchgang denke ist das *pattern matching*.

Die wichtigste Änderung war die Änderung des zentralen `Model` Typs von einem *alias* zu eine *algebarischen Datentypen*.

*vorher*:
```Elm
type alias Model =
  { board : Board
  , currentPiece : Maybe CurrentPiece
  }
```

*nachher*:
```Elm
type Model =
    = RunningGame GameDetails
    | GameOver Board
```

Auch wenn der *"Inhalt"* der beiden Varianten nahezu identisch ist lohnt es sich **jetzt** eine klare Unterscheidung zwischen den beiden Zuständen einzuführen. Eine ganze Reihe von Operationen, beziehungweise Ereignissen machen keinen Sinn mehr wenn das Spiel zu Ende ist.
Indem wir dies als eigene Variante ausdrücken ermöglichen wir es dem Compiler uns zu "allen Stellen zu führen" an denen wir unsere Logik daraufhin untersuchen sollten.

Ein zentrale Stelle ist die `update` Funktion. Wie im Stream erwähnt habe ich mir die Awendung des *pattern matching* für die [`update` Funktion](https://github.com/rtfeldman/elm-spa-example) bei [Richard Feldman](https://twitter.com/rtfeldman) abgeschaut.
Sein [*Elm SPA example*](https://github.com/rtfeldman/elm-spa-example) ist eine vollständige Elm Anwendung bei der man sich einige gute Muster abschauen kann.

Der Anfang der `update` Funktion:

```Elm
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    GravityTick _ ->
      dropCurrentPiece model
```

sieht nach der Bearbeitung wie folgt aus:
```Elm
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case ( msg, model ) of
    ( GravityTick _, RunningGame gameDetails ) ->
      dropCurrentPiece gameDetails
```

In dem wir den Ausdruck zwischen `case` und `of` auf ein Tupel von der `msg` **und** dem aktuellen `model` erweitern können wir jetzt in jedem Zweig neben der Nachricht auch mit dem aktuellen Spielzustand vergleichen.

Desweiteren fügen wir einen Zweig hinzu der für alle Kombinationen aufgerufen wird die wir *nicht* explizit erwähnen.

So ergibt sich die angenehme Situation, dass wir ungültige Kombinationen, wie zum Beispiel `(KeyDown key, GameOver)` nicht spezifieren brauchen.

Das heißt am Ende kommen wir mit weniger Code aus. Weniger Code ist natürlich immer erstrebenswert. Allerdings hat diese Lösung auch einen Nachteil.
In der vorherigen Version weist uns der Compiler auf einen fehlenden Zweig in der `update` Funktion hin sobald wir eine neue Variante für unseren `Msg` Datentypen hinzufügen. Das tut er in der überarbeiteten Version nun nicht mehr, da wir mit dem `_ -> ...` Zweig ja ein "passendes" Muster haben.
Man muss also bei der Anwedung dieser Optimierung gut überlegen was einem wichtiger ist.

- Wieviele Zweige muss ich explizit aufzählen falls ich ohne den `_ -> ..` Zweig arbeite?
- Wie einfach ist es die Stellen zu finden die angefasst werden müssen, wenn ich **mit** dem `_ -> ..` Zweig arbeite? 

