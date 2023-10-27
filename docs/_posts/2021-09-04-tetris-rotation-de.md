---
layout: post
title:  "Episode 8: Rotation und zufällige Teile"
date:   2021-09-04 16:00:00 -0400
ref: tetris-rotation
lang: de
permalink: /elm/de/tetris-rotation
tags: elm
---

<img src="/assets/posts/tetris-rotation/rotation.gif" alt="Rotation" style="float: right; padding-right: 5px"/>
In [Episode 8 (60min)](https://youtu.be/Mv6FOrcLXFs) implementiere ich die Rotation des aktuellen Teils. Das geht so flott, dass ich auch noch hinzufüge das anstelle des gleichen Steins zufällige neue Steine generiert werden.

Die Code-Änderungen von dieser Woche gibt es im [episode8 Branch](https://github.com/axelerator/elm-tetris/tree/episode8) bzw [Commit](https://github.com/axelerator/elm-tetris/commit/4699a918aea8eb7c9de7d3bb03aa3a0350f8a681).


<iframe width="560" height="315" src="https://www.youtube.com/embed/Mv6FOrcLXFs" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

1. [Konsolen-Logging mit Elm](#debug)
2. [Installation und Verwendung von `elm-test`](#elm-test)
3. [Test Driven Development](#tdd)
4. [Wo war der Fehler in Episode 6?](#fail)

### <a name="rotation" /> Rotation

Die Kernfunktion um einen Stein rotieren zu können war schneller hinzugefügt als ich es erwartet hattet. Dank [Shauns Implementierung](https://shaunlebron.github.io/t3tr0s-slides/#4) brauchte ich die nötigen Berchnungen nicht selber herausfinden.

Die Umsetzung verlief ohne große Überraschungen oder Herausforderungen.

### <a name="random" /> Zufällige Teile mit Kommandos

Die zweite Erweiterung die ich eingebaut habe sorgt dafür, dass neue Teile zufällig gewählt werden wenn ein neues Teil erzeugt werden muss.
Dafür musste ich auf ein Konzept zurückgreifen, dass ich bisher umgangen habe: **Commands**.

Da sie eine zentrale Rolle in Elm-Anwendungen spielen möchte ich hier gern nochmal zusammenfassen wozu sie gut sind.

**Commands** sind das logische Gegenstück zu **Subscriptions** die wir uns in [Episode 4](https://blog.axelerator.de/elm/de/tetris-gravity) angeschaut haben.
Mit den **Subcriptions** konnten wir **unsere** Nachrichten mit Ereignissen verknüpfen die 'außerhalb' unserer Anwendung generiert werden (Timer, globaler Tastendruck).
Mit **Commands** lösen wir selber Ereignisse außerhalb unserer Anwendung aus. Da unsere Anwendung rein funtional ist, benötigen wir ein Vehikel um mit der realen, nicht funktionalen Welt interagieren zu können.

In unserem Tetris ist die Generierung von Zufallszahlen ein solch 'nicht funktionaler' Teil. Eine Funktion die bei jedem Aufruf ein anderes Ergebnis erzeugt ist nicht 'rein' und kann daher nicht direkt in unserem Elm-Programm aufgerufen werden.

Ein weiteres prominentes Beispiel für die Verwendung von Commands sind [HTTP Requests](https://guide.elm-lang.org/effects/http.html). Das Aufbauen einer TCP Verbindung und Warten auf ein Ergebnis kann nicht als 'reine' Funktion abgebildet werden:

- Elm kann nicht garantieren, dass der Aufruf immer das gleiche Ergebnis erzeugt
- HTTP requests dauern verhältnismäßig lang - was wenn der Benutzer zwischendurch auf einen Button klicken will

Mit den Commands ersetzen wir das, was in anderen Sprachen ein normaler Funktionsaufruf ist durch zwei **entkoppelte** Schritte:

1. Erzeugen des **Commands**
2. Verarbeiten des Ergebnisses

Dadurch verhindern wir, dass sich unsere Anwendung auf Zusagen verlässt die Elm nicht halten kann.

Für das Erzeugen von **Commands** bietet uns Elm konkrete Stellen in der Anwendung an.
Die wichtigste ist in dem Rückgabetyp der `update` Funktion.

```Elm
update : Msg -> Model -> (Model, Cmd Msg)
```

Wenn wir eine Nachricht verarbeiten können wir nicht nur ein Model, sondern auch ein Kommando zurückgeben.
Diese Kommandos können wir mit Hilfe von Funktionen wie [`generate` zur Generierung von Zufallszahlen](https://package.elm-lang.org/packages/elm/random/latest/Random#generate) oder [`get` für Http Requests](https://package.elm-lang.org/packages/elm/http/latest/Http#get) erzeugen.

Die meisten Kommandos erzeugen irgendeine Art von Ereignis bezieheungsweise Ergebnis das wir weiterverabeiten wollen.
Im `Random#generate` Fall wollen wir die generierte Zufallszahl verwenden um ein neues Tetristeil zu generieren.
Für das Verarbeiten von Ereignissen haben wir bereits die `update` Funktion. **Unser** `Msg` Typ definiert die verschiedenen Varianten von Ereignissen auf die **unsere** Anwendung reagieren kann.

Die Funktionen die Kommandos generiern wissen zwar was für Werte sie generieren aber sie kennen natürlich nicht die Nachrichten die **unsere** Anwensung definiert.
Deswegen hat der `Cmd` Typ einen Typparameter `msg`. Um die [`generate`](https://package.elm-lang.org/packages/elm/random/latest/Random#generate) nutzen zu können müssen wir ihr eine Funktion `(a -> msg)` übergeben, die aus dem Zufallswert `a` (in unserem Fall `Int`) eine Nachricht **unserer** Anwedung erzeugt.

In [unserem Code](https://github.com/axelerator/elm-tetris/blob/episode8/src/Main.elm#L335) rufen wir `generate` wie folgt auf:

```Elm
Random.generate NewCurrentPiece (Random.int 0 <| (length pieceDefinitions - 1))
``` 

`NewCurrentPiece` hat folgende Signatur:

```Elm
NewCurrentPiece : Int -> Msg
```

Die Signatur von `generate` in der Dokumentation lautet:

```Elm
generate : (a -> msg) -> Generator a -> Cmd msg
```

Die kleinen Buchstaben sind Typparameter. Der gleiche Bezeichner (`a` oder `msg`) muss beim Aufruf auch für den gleichen tatsächlichen Typen stehen. Das heißt wenn wir die Typen unseres `generate` Aufrufs auswerten kommen wir zu folgender Situation:

```Elm
generate : (Int -> Msg) -> Generator Int -> Cmd Msg
```
Das schreiben wir nirgendswohin. Es dient lediglich zur Veranschaulichung, dass der finale Ausdruck den Typ `Cmd Msg` hat.
Das großgeschriebene `Msg` ist hier wichtig, denn es ist genau das was der Compiler verlangt, damit wir dieses Kommando von unsere `update` Funktion zurückgeben dürfen.

Die Verarbeitung der Zufallszahl erfolgt dann über den 'normalen' Weg mit dem `NewCurrentPiece` Zweig der [`update` Funktion](https://github.com/axelerator/elm-tetris/blob/episode8/src/Main.elm#L194).



