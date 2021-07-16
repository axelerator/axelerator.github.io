---
layout: post
title:  "Episode 3: Definition und Darstellung der Tetristeile und statische Typisierung"
date:   2021-07-16 16:00:00 -0400
ref: tetris-pieces
lang: de
permalink: /elm/de/tetris-pieces
---

Diese Woche habe ich die Datenstrukturen entwickelt die notwendig sind um die charakteristischen Tetristeile zu definieren und auf unserem Board darzustellen.
Es hat mich auch etwas überrascht, dass es über 1.5 Stunden gedauert hat die ~150 Zeilen zu schreiben, aber ich war schon immer etwas langsamer 😅.

Den Code von dieser Episode gibt es auf Github: [Branch](https://github.com/axelerator/elm-tetris/tree/episode3) [Commit](https://github.com/axelerator/elm-tetris/commit/89196d6adb25f4edadea7aac9af5b865094ea256)

In diesem Artikel:

 - [Was ist ein algebraischer Datentyp?](#adt)
 - [Was ist so toll an diesen Datentypen?](#statictyping)
 - [Automatische Vollständigkeitsprüfung](#exhaustiveness_check)
 - [Pattern matching](#patternmatching)

<iframe width="560" height="315" src="https://www.youtube.com/embed/JhIVeAYEXZU" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>


Als Spotlight für heute möchte ich ein wenig näher auf [algebraische Datentypen](https://de.wikipedia.org/wiki/Algebraischer_Datentyp) und die Stärken statische Typisierung eingehen.

## <a name="adt">Was ist ein algebraischer Datentyp?</a>

Diese Begriffe klingen sehr kompliziert stehen aber für sehr praktische Werkzeuge die mir in anderen Programmiersprachen oft fehlen. Und ich hoffe, dass ich anhand ein paar konkreter Beispiele aus dem Tetrisprojekt zeigen kann, dass sie am Ende auch gar nicht schwer zu verstehen sind.

Algebraische Datentypen (ADT) werden auch manchmal *Summentyp* genannt. Das Verständnis ist das ein solcher Typ die Summe aller deklarierten Varianten bildet. Ein einfaches Beispiel ist unser Typ `FieldColor`:

```Elm
type FieldColor = Blue | Red
```

Wir definieren einen neuen *Typ* mit dem Namen `FieldColor`. Ein Wert von diesem Typ kann entweder ein `Blue` **oder** ein `Red` sein.

Hier sind zwei Ausdrücke vom Typ `FieldColor`

```Elm

iAmRed : FieldColor
iAmRed = Red

iAmNotRed : FieldColor
iAmNotRed = Blue
```

Anzumerken ist hier, dass lediglich `FieldColor` ein neuer Typ ist. `Blue` und `Red` sind Werte oder Varianten und können *nicht* als Typ verwendet werden.

```Elm
iDontCompile : Blue
iDontCompile =
    Blue

Detected problems in 1 module.
-- NAMING ERROR --------------------------------------------------- src/Main.elm

I cannot find a `Blue` type:

1| iDontCompile : Blue

```

Eine andere Art über ADTs zu denken ist die Beziehung zwischen einer abstrakten Oberklasse und seinen Unterklassen in objektorientierten Modellen( wenn man die Tatsache das eine Unterklasse ein Typ is mal ingnoriert).

Dies hilft auch das Verständnis von ADT mit Daten zu fördern. Als Beispiel können wir uns den in dieser Episode eingeführten Datentypen `Field` anschauen.

```Elm
type Field = Empty | Field FieldColor

iAmARedField : Field
iAmARedField = Field Red
```

In Java übersetzt könnte man das Konstrukt wie folgt ausdrücken:

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

Die Namen die auf der Rechten Seite des `=` unserer Typdefinition stehen werden deswegen auch *Konstruktorfunktionen* genannt.

Dieses Beispiel zeigt recht anschaulich wieviel *ausdrucksstärker* Elm ist. Die Bedeutung der Elm beziehungsweise Java-Varianten ist nahezu gleich, aber die Elm-Variante ist deutlich kürzer.

Natürlich ist kürzer nicht automatisch besser. Aber in diesem Fall stammt die zusätzliche Länge ausschließlich von formalen Aspekten wie langen Schlüsselwörtern und Klammerstrukturen.

## <a name="statictyping">Was ist so toll an diesen Datentypen?</a>

Generell dienen Typen dazu um *Bedeutung* auszudrücken. Sie helfen primär dem Entwickler zu verstehen welche Bedeutung ein Codeabschnitt hat.

Bereits die Signatur einer Funktion hilft dem Leser die *Intention* einer Funktion zu verstehen.

```Elm
setField : Position -> FieldColor -> Board -> Board
```

Dies ist eine häufig unterschätze Softwarequalität. Code wird nur einmal geschrieben. 

> Aber Software wird ständig erweitert und muss dafür X mal gelesen und verstanden werden.

Nun kann man argumentieren, dass gut gewählte Parameternamen ähnlich effektiv sind, z.B. könnte eine Rubymethode wie folgt aussehen:

```Ruby
class Board
  def set_field(position, fieldColor)
    ...
  end
end
```
Und es stimmt, dass wir die *Bedeutung* hier fast (was wird zurückgegeben?) genauso gut ablesen können.
Durch die Definition eines Typen in Verbindung mit einem Compiler bekommen wird aber einen zusätzlichen Vorteil.
Falls wir versuchen die Funktion mit falschen Parametern aufzurufen kann uns der Compiler sehr konkretes Feedback geben.

```
The 2nd argument to `setField` is not what I expect:
1|  board = setField ( 5, 3 ) "red"  Blue emptyBoard }
                              ^^^^^
This argument is a string of type:
    String.String

But `setField` needs the 2nd argument to be:
    FieldColor
```

Dieses Feature ist in dynamisch getypten Sprachen völlig abwesend. Niemand hält uns auf diese Funktionen mit Werten aufzurufen die vom falschen Typ sind. Wir versuchen dies mit möglichst hoher Testabdeckung zu verhindern. In kleinen Projekten ist dies kein Problem. In großen Projekten führt es jedoch häufig dazu, dass es sehr lange dauert die Tests auszuführen.
Ein weiterer negativer Seiteneffekt von großen Testsuites ist es, dass bei größeren Refactorings auch große Mengen Tests angepasst werden müssen. Tests die wir in einer statisch getypten Sprache gar nicht erst schreiben müssen.

## <a name="exhaustiveness_check">Automatische Vollständigkeitsprüfung</a>

Im Gegensatz zu dem Klassenbeispiel in Java kann unser Summendatentyp nicht nachträglich erweitert werden. Diese Begrenzung hat einen großen Vorteil: Der Compiler kann für alle Funktionen, die mit Werten dieses Typs umgehen beurteilen ob alle Fälle behandelt wurden.

Nehmen wir zum Beispiel die Funktion die den Farbnamen für ein Feld in unserem Board berechnet:

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

Falls wir unsere Farbdeklaration wie folgt erweitern:


```Elm
type FieldColor = Blue | Red | Green
```

Wird der Compiler uns auf die fehlende Behandlung der `Green` Variante hinweisen:

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

Wir müssen dafür weder Tests schreiben noch externe Tools wie einen [Linter](https://en.wikipedia.org/wiki/Lint_(software)) bemühen.

## <a name="patternmatching">Pattern Matching</a>

In diesem Beispiel haben wir auch bereits *Pattern Matching* betrieben.
Obwohl unser `Field` Typ lediglich zwei Varianten hat, lässt uns Elm auch auf den *"Datenwert"* der `Field`-Variant "matchen".

Eine Variante mit einem Level weniger pattern matching ist deutlich verboser:

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

Das heißt nicht, dass diese Lösung nicht auch Sinn machen kann. Letztendlich ist es eine Abwägung zwischen *Coupling* oder *Cohesion* - also was ist mir wichtiger: "Alles an einem Ort" oder "Ein Ding macht nur eine Sache".
Mit der Flexibilität die Elm uns durch pattern matching gibt kann der Entwickler entscheiden wo Zusammenhänge komprimiert oder getrennt werden.
