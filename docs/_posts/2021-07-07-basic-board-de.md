---
layout: post
title:  "Episode 2: Darstellung des leeren Boards und partielle Anwendung"
date:   2021-07-07 20:00:00 -0400
ref: basic-board
lang: de
permalink: /elm/de/board
tags: elm
---

Nachdem wir uns letzte Episode Zeile für Zeile durch die *Hello World* Anwendung gekämpft haben, schauen wir heute nochmal etwas abstrakter auf die Natur
einer Elm-Anwendung bevor wir uns ans Programmieren begeben.

[<img src="/assets/posts/basic-board/architecture.png" width="300" />](/assets/posts/basic-board/architecture.png)

Danach bringen wir unseren Protoypen in einen Zustand wo er das leere Board darstellt. Den Zustand den der Code nach der Episode hat ist im [episode2 Branch auf Github ](https://github.com/axelerator/elm-tetris/tree/episode2) verfügbar.

<iframe width="560" height="315" src="https://www.youtube.com/embed/rJXE328qYz8" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

Die Entwicklung einer Elm Anwedung startet meistens mit Überlegungen über die Grundlegenden Datentypen. Dabei müssen wir nicht alles "durchdesignen".
Wir fangen mit einem sehr begrenzten Datenmodell an, dass ausschließlich leere Zeilen kennt an. Ich habe Vetrauen, dass das starke Typesystem von Elm es mir ermöglicht 
das Modell Stück für Stück schnell zu erweitern ohne Regressionen einzuführen.

Die Art wie wir Funktionen in Elm definieren kommt Benutzern anderer Sprachen oft komisch vor:

```Elm
fieldView : Int -> Int -> Html Msg
fieldView row column =
  rect [x (col * 10), y (row * 10)] []
```

Die erste Zeile ist die Funktionssignatur und lässt sich wie folgt interpretieren:

> `fieldView` ist eine Funktion mit zwei Integer Parametern
> und gibt einen Wert vom Typ `Html Msg` zurück.

## "Aber warum sind die Parameter nicht zum Beispiel in Klammern vom Rückgabewert getrennt?"
Der Grund dafür ist, dass dies nicht der einzige Weg ist die Signatur zu lesen!

Die Funktionssignatur kann man auch wie folgt lesen:

> `fieldView` ist eine Funktion mit **einem** Integer Parameter.
> Der Rückgabewert ist **eine (neue) Funktion** die einen (den anderen) Integer Parameter
> entgegennimmt und ein `Html Msg` zurückgibt.

Praktisch heißt das jenachdem mit wieviele Parametern wir tatsächlich `fieldView` aufrufen bestimmt ob wir einen Wert oder eine Funktion zurück bekommen.

## "Aber wozu ist das gut!?"

Die Anwedung dieses Prinzips heißt **partielle Anwendung** und wird erst so richtig praktisch wenn wir Funktionen verwenden die andere Funktionen als Parameter erwarten.

Das prominenteste Beispiel einer solchen Funktion ist [map](https://package.elm-lang.org/packages/elm/core/latest/Array#map).
Sie wendet die übergebene Funktion auf die Elemente einer Liste an.

Ein vereinfachte Version der Darstellung des Boards sieht wie folgt aus:

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

Dieser Code kann nicht kompiliert werden, weil der Rückgabewert von `rowView` nicht stimmt. 
Wir übergeben `fieldView` an `map`. Ein Funktion die, wenn wir ihr einen `Int` geben eine Funktion zurückgibt.
Wir wollen aber ein `Html Msg` haben. Die Lösung ist die Zeilennummer durch partielle Anwedung von rowView in eine neue Funktion "einzubacken".

Eine sehr verbose Art dies zu tun sieht wie folgt aus:

```Elm
-- nimmt *einen* Int
-- gibt eine Funktion von Int -> Html zurück
fieldInRow : Int -> (Int -> Html Msg)
fieldInRow rowNumber = fieldView rowNumber -- partielle Anwedung hier!

rowView : Int -> Html Msg
rowView rowNumber =
  let
    columnNumbers = range 0 10
  in
    map (fieldInRow rowNumber) columnNumbers
```

Und jetz kommt der Moment ![mind blown](/assets/mindblown.gif) .
Wenn wir die Klammern in der Definition `fieldInRow : Int -> (Int -> Html Msg)` weglassen, sehen wir, dass es genau die gleiche ist
wie `fieldView : Int -> Int -> Html Msg`.

Und die Bedeutung ist ebenfalls exakt die gleiche. Also können wir uns die gesamte Funktion `fieldInRow` sparen und statt dessen direkt schreiben:

```Elm
rowView : Int -> Html Msg
rowView rowNumber =
  let
    columnNumbers = range 0 10
  in
    map (fieldView rowNumber) columnNumbers
```

Das ist die Ausdrucksstärke und Elegeanz von Elm!
