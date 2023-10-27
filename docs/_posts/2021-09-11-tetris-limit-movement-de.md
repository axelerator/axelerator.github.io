---
layout: post
title:  "Episode 9: Eingeschränkt bewegungsfähig"
date:   2021-09-11 16:00:00 -0400
ref: tetris-limit-movement
lang: de
permalink: /elm/de/tetris-limit-movement
tags: elm
---

In [Episode 9 (48min)](https://www.youtube.com/watch?v=ZacgfAavKzQ) stelle ich sicher das wir das aktuelle Teil nicht außerhalb des Spielbretts oder in andere Teile hineinbewegen können. Dabei muss ich zwei Argumente einer Funktion umdrehen und nutze dies für eine funktionale Fingerübung.

Die Code-Änderungen von dieser Woche gibt es im [episode9 Branch](https://github.com/axelerator/elm-tetris/tree/episode9) bzw [Commit](https://github.com/axelerator/elm-tetris/commit/c9e1d2564626e3584e96500ee210ad14a7a9b1c4).


<iframe width="560" height="315" src="https://www.youtube.com/embed/ZacgfAavKzQ" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

1. [Bewegung erlaubt?](#canmove)
2. [Exkurs *Currying*](#curry)

### <a name="canmove" /> Bewegung erlaubt?

Der Einstiegspunkt für diese Episode war die [`movePiece` Funktion](https://github.com/axelerator/elm-tetris/blob/episode8/src/Main.elm#L222). Das Ziel war es hier Logik hinzuzufügen die die Ausführung der Bewegung nur zulässt, wenn die Spielregeln es auch zulassen.

Mit fast 50 Zeilen Code ist die `movePiece` Funktion bereits verhältnismäßig lang. Doch durch Nutzung ein paar einfacher Syntaxelemente bleibt die finale Funktion mit der zusätzlichen Funktionalität bei der gleichen Länge.

Die Erklärung für 'was erlaubt' ist, habe ich in meinem Kopf wie folgt definiert: 

> Alle Plätze die der aktuelle Spielstein einnehmen **würde**, wenn die Bewegung ausgeführt wird müssen leer sein.
> Wenn das nicht der Fall ist, wird die Bewegung nicht ausgeführt.

Der signifankte Teil der sich geändert hat sieht wie folgt aus:

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

Hohe Softwarequalität drückt sich meiner Meinung nach darin aus, wenn sich das 'mentale Modell' möglichst direkt aus dem Code ablesen lässt.

Die Art wie sich Ausdrücke in Elm kombinieren lassen ermöglicht dies meiner Meinung nach sehr elegant.
Wenn wir die Berechnung von `canMove` von unten nach oben lesen, ist `canMove` wahr wenn:

- die Positionen des bewegten Teils (`occupiedPositions movedPiece`)
- transformiert in welchen Zustand dieses Feld auf dem aktuellen Brett hat (`map (flip lookUp model.board)`)
- alle leer sind (`all ((==) (Just Empty))`)

### <a name="curry" /> Exkurs *Currying*

Das funktionalen Programmieren habe ich dank meines ehemaligen Professor [Uwe Schmidt](https://github.com/UweSchmidt) entdeckt. Die theoretischen Hintegründe aus der Vorlesung sind jedoch nur teilweise hängengeblieben. Und so bin ich im Livestream doch etwas ins Stolpern geraten als es darum ging zu erklären was genau bei der [`flip` Funktion](https://github.com/axelerator/elm-tetris/blob/episode9/src/Main.elm#L250) passiert.

Deswegen gebe ich hier nun eine etwas detailierte Erklärung dazu was `Currying` bedeutet.
In den [vergangenen Episoden](https://blog.axelerator.de/elm/de/board) habe ich mehrfach von *'partieller Anwendung'* Gebrauch gemacht. 

`Currying` beschreibt den Vorgang eine Funktion so aufzubrechen, dass jeder Parameterwert einzeln aufgerufen/gebunden werden kann. Bei Sprachen wie Elm und Haskell bekommen sind Funktionen 'von Haus aus' gecurried.

In JavaScript is Currying auch möglich, allerdings müssen wir es hier explizit ausfomulieren.

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

Funktionen die "gecurried" sind sind vielseitiger einsetzbar als ihre nicht-gecurrieten Gegenstücke. Bereits in unserem kleinen Tetrisprogramm machen wir davon ein paar mal gebraucht.

Currying alleine macht ein Programm nicht autmatisch X% besser. Ich würde sogar behaupten, dass wenn man in einer Sprache wie JavaScript in der man seine Funktionnsdefinition umschreiben muss, der Aufwand es nicht wert ist.

In Sprachen jedoch wo es currying 'gratis' dazu gibt, wird es zu einer Selbstverständlichkeit die man schnell nicht mehr missen möchte. Und je größer ein Softwareprojekt wird, desto größer sind die Effizienzgewinne von solch kleinen Optimierungen.

Ein 'Fun Fact' den man nennen muss, wenn man über Currying spricht ist, dass es nach [Haskell Curry](https://de.wikipedia.org/wiki/Haskell_Brooks_Curry) benannt wurde. Seine Ideen beruhen auf den Grundlagen der kobinatorischen Logik die von [Moses Schönfinkel](https://de.wikipedia.org/wiki/Moses_Sch%C3%B6nfinkel) vor **über 100 Jahren** entwickelt wurden.
Der Name 'Currying' hat sich mutmaßlich durchgesetzt, weil eine Funktion 'schönfinkeln' halt nur im deutschen Sprachraum von der Zunge rollt.

