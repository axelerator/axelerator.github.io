---
layout: post
title:  "Episode 6 & 7: Kollisionserkennung und Test Driven Development"
date:   2021-08-26 20:00:00 -0400
ref: tetris-collision
lang: de
permalink: /elm/de/tetris-collision
---

<img src="/assets/posts/tetris-collision/collision_cropped.gif" alt="Kollisionserkennung" style="float: left; padding-right: 5px"/>Diese Woche gibt es einen kombinierten Artikel die beiden letzten Episoden. Inhaltilich habe ich mich in beiden Sitzungen mit der Kollisionserkennung auseinadergesetzt. Nachdem ich in [Episode 6](https://www.youtube.com/watch?v=KXtmFh0C-9s) kniffligen Bug eingebaut hab, nehme ich in [Episode 7](https://www.youtube.com/watch?v=ZXMQCuvLHMg) die Gelegenheit wahr zu zeigen wie Test Driven Development mit `elm-test` helfen kann solche Situationen zu vermeiden.

Episode 7 [on Github](https://github.com/axelerator/elm-tetris/tree/episode7)
<iframe width="560" height="315" src="https://www.youtube.com/embed/ZXMQCuvLHMg" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>


1. [Konsolen-Logging mit Elm](#debug)
2. [Installation und Verwendung von `elm-test`](#elm-test)
3. [Test Driven Development](#tdd)
4. [Wo war der Fehler in Episode 6?](#fail)

### <a name="debug" /> Konsolen-Logging mit Elm

Für Episode 6 war ich irgendwie nicht so gut drauf und hab einen Logikfehler eingebaut. Ich habe verschiedene Vermutungen gehabt (die alle falsch waren) und versucht mit Hilfe vieler temporärer Testausgaben dem Problem zu Leibe zu rücken.

Elm kommt mit ein [`Debug` Paket](https://package.elm-lang.org/packages/elm/core/latest/Debug). Mit der [`log` Funktion](https://package.elm-lang.org/packages/elm/core/latest/Debug#log) können wir Ausdrücke in der JavaScript Konsole loggen - ähnlich wie mit [`console.log`in JavaScript](https://developer.mozilla.org/en-US/docs/Web/API/console/log).

Allerdings folgt der Aufruf einem auf den ersten Blick eigenartigem Pattern.
Um den Parameter `a` dieser Beispielfunktion auszugeben schreiben wir:
```Elm
sumIt : Int -> Int -> Int
sumIt a b =
  let
    _ = Debug.log "a is:" a
  in
    a + b
```

Warum können wir nicht einfach nur `Debug.log "a is:" a` schreiben? Der Grund dafür ist, dass der `let` Block ausschließlich dazu dient lokale Ausdrücke zu benennen.
`Debug.log` ist die **einzige** Funktion in Elm die nicht **pure** ist und für deren Rückggabewert wir uns nicht interessieren.
**Alle anderen** Funktionen rufen wir auf um an den berechneten Wert zu kommen (und ihm im `let` einen lokalen Namen zu geben).
Damit das Format wie wir `Debug.log` aufrufen dasselbe ist wie das der "normalen" Ausdrücke im `let` Block weisen wir den Ausdruck den Namen `_`(Unterstrich) zu.
Mit dieser Konvention wird vermieden, dass der Compiler eine extra Syntax-Regel ausschließlich für die `Debug.log` Anweisung haben muss.

Der Unterstrich kommt nicht nur hier zum Einsatz, sondern wird generell als Bezeichner verwendet wenn wir uns für den Inhalt des Ausdrucks nicht interessieren.  

Zum Beispiel auch in unserer [mkEmptyRow](https://github.com/axelerator/elm-tetris/blob/episode5/src/Main.elm#L137) Funktion:

```Elm
  mkEmptyRow _ =
      Row <| map (\_ -> Empty) (range 1 11)
``` 

Wir nutzen den "Wiederholungscharakter" der [`map` Funktion](https://package.elm-lang.org/packages/elm/core/latest/List#map) um eine Funktion für jedes Element in einer [range](https://package.elm-lang.org/packages/elm/core/latest/List#range) aufzurufen.
Allerdings interessieren wir uns nicht für die tatsächliche Zahl.
Wir geben dem Leser frühzeitig einen Hinweis darauf in dem wir anstatt einen Namen den Unterstrich als Parameternamen verwenden.


### <a name="elm-test" /> Installation und Verwendung von `elm-test`

Wie im Video beschrieben ist `elm-test` ein eigenes Programm das zusätzlich installiert werden muss bevor wir es verwenden können.

Die Ausführung des von Elm zu JavaScript umgewandelten Codes in der Kommandozeile wird durch die Verwendung von Node.js umgesetzt.
Es ist daher wenig überraschend das für die Installation der Paketmanager `npm`, der zu Node.js gehört,  zum Einsatz kommt.

Das heißt bevor man `elm-test` installieren kann muss man zunächst Node.js installieren. Dafür gibt es je nach Betriebssystem mehrere Wege neben dem [Herunterladen von der offiziellen Seite](https://nodejs.org/en/).

Ich verwende [nodeenv](https://github.com/nodenv/nodenv) um meine Node-Umgebung zu verwalten. Dieses ermöglicht verschiedene Node-Versionen gleichzeitig installiert zu haben, aber nicht zwingend notwendig.

### <a name="tdd" />Test Driven Development

Mein gescheiterter erster Versuch war eine gute Gelegenheit die Stärken des **Test Driven Development** (kurz **TDD**) Ansatzes zu demonstrieren.

TDD ist keine Elm spezifische Technik. Es ist eine von mehreren Techniken der ["Extreme Programming"](https://de.wikipedia.org/wiki/Extreme_Programming) Methode die bereits um die Jahrtausendwende von [Kent Beck](https://twitter.com/KentBeck) populär gemacht wurde.

Bei dieser Technik schreiben wir **zuerst** einen Test bevor wir mit der Implementierung beginnen. Aber warum?

Als Entwickler habe ich häufig schon eine konkrete **Lösung** im Kopf. Wie man in Episode 6 sieht ist es sehr verlockend sich **zuerst** um die Implementierung zu kümmern. Funktionsnamen und Parameter dienen dann lediglich dazu alles "zusammenzufügen".

TDD zwingt uns **zuerst** über die API/Signatur/Namen der neuen Funktionalität nachzudenken. Das führt in aller Regel dazu, dass die neuen Funktionen besser benannt und besser testbar sind.

TDD heißt auch wir starten mit dem einfachsten/naivesten Test. Wir folgen dann einem regelmäßigen Wechsel aus: 

- Implementierung erweitern um bestehenden Test zu erfüllen
- Neuen, erfolglosen Testfall hinzufügen, der eine zusätzliche Bedingung prüft

In der Episode mache ich zunächst meine Änderungen aus Episode 6 rückgängig um das Problem von Vorne anzugehen.
Über die Dauer der Episode ist zu sehen wie der TDD Ansatz dazu führt, dass ich die ganze Zeit eine vollständige Testabdeckung habe.
Dies zahlt sich spätestens dann aus, als ich mit einer späteren Änderung die bisher erarbeite Logik kaputt mache.
Dank der bis dahin geschriebenen Tests ist der Fehler schnell und mit deutlich weniger `Debug.log` Ausdrücken gefunden.

### <a name="fail"/>Wo war der Fehler in Episode 6?

Ich war ziemlich müde als ich die Episode aufgenommen hab. Aber ich musste natürlich trotzdem noch rausfinden woran es gelegen hat! Hast du den Fehler entdeckt?

Der Fehler war in der Berechnung der Teile die der Stein einnehmen **würde**.
Der Ausdruck `translateTile` Verwendet jedoch die **aktuelle** Position des `currentPiece`.

Falsch:
```Elm
  translateTile ( tx, ty ) =
      ( x + tx, y + ty )
```

Richtig:
```Elm
  translateTile ( tx, ty ) =
      ( x + tx, nextRow + ty )
```

Dazu hab ich noch zusätzliche Fehler beim Debuggen eingebaut (`- 1` beim `drop`) die auch noch rückgängig gemacht werden müssten.
Am Ende bin ich aber sehr zufrieden die Extrarunde über `elm-test` gedreht zu habem. Jetzt wo ich ein funktionierendes Test-Setup hab, werde ich sicher häufiger darauf zurückgreifen!

