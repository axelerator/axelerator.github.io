---
layout: post
title:  "Episode 10: Komplette Reihen verschwinden mit Falten"
date:   2021-09-16 19:00:00 -0400
ref: tetris-clear-rows
lang: de
permalink: /elm/de/tetris-clear-rows
tags: elm
---

<img src="/assets/posts/tetris-clear-rows/teaser.gif" style="float:left; margin: 5px 10px 10px 0"/>
Damit mein Tetris spielbar wird sorge ich in [Episode 10 (55min)](https://www.youtube.com/watch?v=b1vnT6XTFP4) 
dafür, dass vollständige Zeilen verschwinden. Mit mehr Unit-Tests und der Anwendung der Faltung einer Liste nähere ich mich einem vollständigen Version.


Die Code-Änderungen von dieser Woche gibt es im [episode10 Branch](https://github.com/axelerator/elm-tetris/tree/episode10) bzw [Commit](https://github.com/axelerator/elm-tetris/commit/74ac057b1037e10cd6c47b63647952c943054718).

<iframe width="560" height="315" src="https://www.youtube.com/embed/b1vnT6XTFP4" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

Es ist immer sehr befriedigend wenn man sich einen Plan zurechtlegt und die Ausführung dann auch einigermaßen danach abläuft.
Dementsprechend hat die Aufzeichnung dieser Episode auch Spaß gemacht. Die initiale Idee war es die `eraseCompleteRows` zu entwickeln, welche ein Board von den vollständigen Reihen befreien sollte.

Da ich bereits in [Episode 7](/elm/de/tetris-collision) ein Setup für automatisierte Tests eingerichtet hatte, fiel die Entscheidung nicht schwer diesmal gleich mit einem Test loszulegen.

Der Algorithmus für den ich mich am Ende entschieden habe läuft wie folgt ab:

1. Durchlaufe alle Zeilen des Spielbretts:
 - *1a* für eine **unvollständige** Reihe: Sammele sie als *"Boden"*-Reihe für das Folgespielbrett
 - *1b* für eine **vollständige** Reihe: Sammel eine leere *"Kopf"*-Reihe in einer Extra-Liste

2. Erstelle das Folgespielbrett mit den *"Boden"*-Reihen (1a) unten und hänge die *"Kopf"*-Reihen (1b) darüber.

Bei der Implementierung habe ich mich für die Nutzung der `foldr` Funktion entschieden. Da einige Programmierer Angst vor dieser Funktion zu haben scheinen möchte ich hier die Gelegenheit nutzen ein paar Unklarheiten zu breinigen.

### Wofür ist `foldr` gut?

`foldr` existiert in vielen Sprachen, sie heißt nur manchmal anders:

- [reduce](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/Reduce) in JavaScript
- [inject](https://ruby-doc.org/core-3.0.2/Enumerable.html#method-i-inject) in Ruby

Ähnlich wie `map` können wir `fold` eine Funktion als Parameter übergeben, die für jedes Element ausgeführt wird. Im Gegensatz zu `map` braucht das Ergebnis allerdings nicht zwingend eine Liste zu sein, sonder kann von einem beliebigem Typ sein.
In diesem Sinne ist `fold` also *"mächtiger"* als `map`. 

Diese Macht erkaufen wir uns allerdings auch mit etwas mehr Komplexität. Vergleichen wir einmal die Signaturen von `map` und `foldr`:

```Elm
map :   (a -> b)             -> List a -> List b

foldr : (a -> b -> b)  ->  b -> List a -> b
```

`map` ist einfach: Es verwandelt eine Liste von Elementen vom typ `a` in eine gleich lange Liste von Elementen vom Typ `b`. Dafür verwendet `map` die Funktion `(a -> b)` die wir übergeben.

Ich habe die einzelnen Parameter in Signaturen bewusst ausgerichtet um die Unterschiede zu verdeutlichen.
Für `fold` taucht `b` jetzt an viel mehr Stellen auf! 
Der Rückgabewert ist jetzt nur noch `b` anstatt `List b`!
Unsere "Faltfunktion" ist nicht mehr `(a -> b)` sondern `(a -> b -> b)`. Das heißt um den Rückggabewert *pro Element* zu berechnen müssen wir zusätzlich einen weiteren Wert vom selben Typ wie dem Ergebnis unserer Faltoperation konsumieren.
Und dann ist da noch das `b` "in der Mitte" - der zweite Parameter den wir `foldr` übergeben müssen, bevor wir es auf die Liste von `a` anwenden können.

Wie immer wird hoffentlich alles klarer wenn wir uns ein einfaches Beispiel anschauen. 
Sagen wir mal, wir möchten eine Funktion `totalLength` implementieren die Anzahl aller Buchstaben in einer Liste von Wörter berechnet.

```Elm
totalLength : List String -> Int
``` 

In einer imperativen Sprache mit [`for`-Schleife](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/for...in) können wir das ganze so berechnen:

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

Eine solche Lösung wäre nicht zulässig in Elm da wir keine *Variablen* haben deren Wert wir überschreiben können. Deswegen gibt es auch keine `for`-Schleife in Elm. Aber `fold` erledigt den gleichen Job mindestens genauso gut. Um zu verstehen wie man `foldr` verwendet bauen wir unsere JavaScript-Lösung von oben wie folgt um.

Refaktorisierung 1:

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

Refaktorisierung 2:

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

Jetzt haben wir unsere eigene `fold`-Implementierung in JavaScript geschrieben. Und genaus wie wir sie dort verwenden rufen wir sie auch in Elm auf:

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

## Anwendung von `fold` in `eraseCompleteRows`

Die Funktion heißt `fold` oder `reduce` weil wir häufig eine potentiell lange Liste auf einen *kleinen, einzelnen* Wert reduzieren.

Wie einfach der Wert ist auf den reduzieren hängt von der Funktion ab mit der wir "falten".
Die [Anwendung von `fold` in `eraseCompleteRows`](https://github.com/axelerator/elm-tetris/blob/74ac057b1037e10cd6c47b63647952c943054718/src/Main.elm#L396) erzeugt als Rückgabewert ein Paar von Listen von Reihen. 

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

Wenn wir die Typparameter in unserem `foldr` Ausdruck auswerten ergibt das die folgenden Typen.
Ich definiere zunächst einen Typalias, damit alles in eine Zeile passt.

```Elm
type alias RowTuple = (List Row, List Row)

foldr : ( a   ->    b    ->     b   )  ->   b  -> List  a  ->    b
foldr : (Row -> RowTuple -> RowTuple)  ->  RowTuple -> List Row -> RowTuple
``` 

Der zweite Parameter für `foldr` ist also der `b` für den ersten Aufruf unserer "Faltfunktion". Jeder weitere Aufruf bekommt als `b` den Rückggabewert der "Faltfunktion" des vorherigen Listenelements.

Das erstemal das unsere `folder`-Funktion von aufgerufen wird:

```Elm
folder : Row -> ( List Row, List Row ) -> ( List Row, List Row )
folder row ( nonEmptyRows, header ) = ..
```

enthält `row` die erste Reihe und `( nonEmptyRows, header )` hat den Wert `( [], [] )`, denn das ist der zweite Parameter in unserem Aufruf: `foldr folder ( [], [] ) board.rows`.

- Ist diese Reihe voll hängen wir eine leere Reihen an den hinteren Wert des Paares. 
- Ist die Reihe *nicht* voll, hängen wir sie an den vorderen Teil des Paares. 

Der so berechnete Rückgabewert wird (neben der nächsten Reihe) der neue Eingabewert für den nächsten `folder-Aufruf. Das wird solange wiederholt bis wir alle Reihen bearbeitet haben.
Danach haben wir zwei Listen in dem Ergebnispaar: Eine mit 'unvollständigen' Reihen die den unteren Teil des Bretts bilden, und eine Liste mit leeren Reihen die wir oben drauf packen um die entfernten, vollständigen Reihen zu kompenieren.

<img src="/assets/posts/tetris-clear-rows/fold.svg" style="width: 100%"/>
