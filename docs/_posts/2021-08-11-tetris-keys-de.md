---
layout: post
title:  "Episode 5: Registrierung von Tastendruck"
date:   2021-08-13 15:00:00 -0400
ref: tetris-key-strokes
lang: de
permalink: /elm/de/tetris-key-strokes
tags: elm
---

In [dieser Episode (40min)](https://www.youtube.com/watch?v=JG3zzF_jRVc&t=1013s) schauen wir uns an wie wir auf globale Tastaturereignisse reagieren. Wir bemühen ein weiteres mal das *Subscription-System* welches wir [letztes mal](/elm/en/tetris-gravity) kennengelernt haben.

In dieser Nachbereitung gehe ich nocheinmal auf die folgenden Themen ein:

1. [Stapeln von mehreren Subscriptions](#subs)
2. [Warum ist JSON Parsen/Dekodieren in Elm so kompliziert?](#parsing)
3. [Wie funktioniert unser `keyDecoder`?](#decoder)

<iframe width="560" height="315" src="https://www.youtube.com/embed/JG3zzF_jRVc" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

Den Code von dieser Episode gibt es auf Github: [Branch Episode5](https://github.com/axelerator/elm-tetris/tree/episode5) [Commit](https://github.com/axelerator/elm-tetris/commit/ff76dcab313f67bd8e878857dfa8cd0af18e2c53)


### <a name="subs"/>Stapeln von Subscriptions

Wie wir bereits letzte Episode gesehen haben gehören die `subscriptions` zu den Ausdrücken die wir als Teil unserer 'Anwendungswurzel' deklarieren

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

Die erwartete Signatur ist sehr explizit darüber, dass sie genau **eine** `Sub Msg` erwartet. Wir haben aber bereits in der letzten Episode eine Subscription für die Gravitation registriert:


```Elm
subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every 1000 GravityTick
``` 

Wie ich im Video zeige können wir den Ausdruck nicht einfach in eine Liste umwandeln. Der Ausdruck `[Time.every 1000 GravityTick, onKeyDown keyDecoder]` hat den Typ `List (Sub Msg)`. Das ist nicht kompatibel mit dem erwarteten `Sub Msg`.

Um dies zu umgehen nutzen wir die [`batch`](https://package.elm-lang.org/packages/elm/core/latest/Platform-Sub#batch) Funktion. Mit dieser können wir mehrere Subscriptions in eine einzelne "einwickeln". Dies Funktioniert auch mehrfach. Das heißt ein "batch" kann wiederum mehrere "batches" enthalten. Hauptsache wir haben am Ende eine **einzelne** Subscription die wir "anmelden" können.

Die finale Lösung sieht in unserem Fall so aus:

```Elm
subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Time.every 1000 GravityTick
        , onKeyDown keyDecoder
        ]
``` 

### <a name="parsing"/>Warum ist JSON Parsen/Dekodieren in Elm so kompliziert?

Wie bereits im Video erwähnt werde ich hier nicht versuchen eine vollständige Einführung in JSON-Verarbeitung zu geben.
Im offiziellen Elm Guide gibt es eine [kurze Einführung](https://guide.elm-lang.org/effects/json.html) die jedoch kompliziertere Fälle offen lässt.
Für weiterführende Anleitungen gibt es bereits zahlreiche Artikel online wie zum Beispiel auf [elmprogramming.com](https://elmprogramming.com/decoding-json-part-1.html#decoding-json)

Verglichen zu Sprachen mit weniger eingebauten Garantien erscheint der Ansatz von Elm zunächst unnötig kompliziert und unintuitiv.

Ich habe am Anfang ziemlich damit gekämpft und hoffe das ich mit der kleinen Zusammenfassung hier zeigen kann, dass sich der Aufwand lohnt.

Am Ende dieser Episode haben wir einen JSON Decoder der wie folgt definiert ist:

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

Die [`toKey`](https://github.com/axelerator/elm-tetris/blob/ff76dcab313f67bd8e878857dfa8cd0af18e2c53/src/Main.elm#L246) ist trivial, denn sie wandelt lediglich eine Zeichenkette in eine `Msg` um.
Aber der `keyDecoder` hat es in sich! Um ihn besser zu Verstehen schauen wir erstmal was ein **Decoder** ist.
Die Elm Dokumentation sagt dazu:

> `type Decoder a`<br />
> A value that knows how to decode JSON values.

Und schickt uns in den [offiziellen Guide](https://guide.elm-lang.org/effects/json.html) für mehr Details.
Ich versuche eine alternative Erklärung zu geben die hoffentlich ein paar Fragen beantwortet die Entwickler haben die aus weniger 'funktionalen Umgebungen' kommen.

Ein `Decoder` ist also "Ein Wert der weiß wie JSON Werte zu dekodieren sind". Das erste was auffällt ist, dass unser `keyDecoder` keinen Parameter animmt. Das ist im Sinne der Definition, denn wir berechnen nicht einen Wert aus gegebenen Parametern sondern geben einen konstanten Ausdruck zurück.

Das bringt die Frage auf: "Wie kann ein **konstanter Wert** etwas dekodieren?"
Das bringt uns zu den Grundprinzipien der funktionalen Programmierung zurück: Funktionen **sind** Werte.
In der Dokumentation sehen wir lediglich die 'linke Seite' der Typdefintion. 
Es kann also durchaus sein, dass dieser Typ aus Varianten gebildet die eine Funktion enthalten.

Die [Decoder-Bibliothek](https://package.elm-lang.org/packages/elm/json/latest/Json-Decode) enthält eine handvoll vordefinierter `Decoder` und Funktionen mit denen wir diese zu komplexeren Dekodierern zusammensetzen können.

Ein Typ dessen "rechte" Seite der Definition `type Decoder a = ???` wir nicht kennen wird auch ein **opaquer Typ** genannt.
Das heißt der Entwickler dieses Typs möchte nicht, dass wir die Implementierungsdetails kennen. Auf den ersten Blick mag das unnötig einschränkend wirken.
Richtig eingesetzt sind opaque Typen aber extrem **befreiend**. Es bedeutet, dass ich als Anwedungsentwickler mich nicht unnötig mit Implementierungsdetails auseinanderzusetzen brauch. Und da ich mit diesem Teil des Systems nicht interagieren kann, kann ich es auch nicht 'falsch bedienen' oder kaputt machen.

Anhand unseres `keyDecoder` werden wir sehen wir ein solcher Typ, obwohl wir nichts über seine Interna wissen, dennoch sehr nützlich sein kann.

Um `Decoder` besser zu verstehen schauen wir uns zunächst einmal an wie er unabhängig von der Tastaturerignisverwaltung eingesetzt werden kann. 
Zur Erinnerung nocheinmal die Definition:

```Elm
keyDecoder : Decode.Decoder Msg
keyDecoder =
    Decode.map toKey (Decode.field "key" Decode.string)
```

Das folgende ist ein komplettes Beispiel um eine JSON Zeichenkette mit Hilfe unseres `keyDecoder` in eine Msg umzuwandeln.
Der zentrale Aufruf ist die Funktion [`Decode.decodeString`](https://package.elm-lang.org/packages/elm/json/latest/Json-Decode#decodeString) die einen `Decoder` und einen `String` erwartet und versucht einen Wert des Zieldatentypen (`Msg`) zu erzeugen.


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

Die JSON Bibliothek ist ein gutes Beispiel für das ["Separation of concerns" Prinzip](https://en.wikipedia.org/wiki/Separation_of_concerns).
Die Funktionen die wissen wie man ein `String`-Wert aus eine JSON-Objekt extrahiert sind in dem opaquen `Decoder` Typ weggekapselt.
Unsere Definition welche **Struktur** wir uns von dem JSON 'wünschen' kommt ohne jegliches Wissen aus wie JSON das JSON Verarbeitet wird. Diese Definition ist desweiteren komplett getrennt von der tatsächlichen **Ausführung**.

Der Hauptvorteil dieser strikten Trennung kommt zum Vorschein wenn wir versuchen ein unvollständiges JSON zu parsen.
`decodeString` kann nicht garantieren das wir ein `Msg` Wert aus der Zeichenkette erzeugen können.

Wenn wir einen Tipfehler in unser JSON einbauen (`key -> keX`): 

```Elm
  jsonString =
      "{ \"keX\" : \"ArrowLeft\"}"
```

Laufen wir in den `Err e -> ...` Fall und bekommen wir folgende Ausgabe in der JavaScript Konsole folgende Ausgabe:

```
invalid: "Problem with the given value:
  { \"keX\": \"ArrowLeft\" }
Expecting an OBJECT with a field named `key`"
```
Das heißt sobald wir unseren `Decoder` spezifiziert haben 

- zwingt uns das Typsystem Parserfehler explizit zu behandeln
- gibt uns im Fehlerfall sehr genaue Beschreibung wo das Problem liegt

Bei so einfachem JSON wie in unserem Beispiel ist dies offensichtlich nicht nötig. Bei Realwelt-APIs die kontinuierlichen Änderungen unterliegen ist dieses Verhalten jedoch sehr wertvoll.

### <a name="decoder"/>Wie funktioniert unser `keyDecoder`?

Im Video habe ich die Definition von `keyDecoder` fast 1:1 aus dem [Beispiel](https://github.com/elm/browser/blob/1.0.2/notes/keyboard.md) kopiert.
Um ihn besser zu Verstehen können wir unsere Definition wie folg aufbrechen ohne die Funktion zu verändern:


```Elm
keyDecoder : Decode.Decoder Msg
keyDecoder = Decode.map toKey keyNameDecoder

keyNameDecoder : Decode.Decoder String
keyNameDecoder = Decode.field "key" Decode.string
```

Die ausgeglierderte `keyNameDecoder` Hilfsfunktion ist jetzt ein Dekodierer der aus einem JSON Objekt ein String auslesen möchte.
Wenn er ausgeführt wird sucht er nach dem Wert der unter dem Schlüssel `key` hinterlegt ist.
Ist dieser nicht vorhanden oder nicht vom Typ `String` wird die Dekodierung fehlschlagen.

Der magische Kleber hier ist allerdings die [`Decode.map` Funktion](https://package.elm-lang.org/packages/elm/json/latest/Json-Decode#map)

```Elm
map : (a -> value) -> Decoder a -> Decoder value`
```

Zum besseren Verständnis setzen wir die Typen aus unserem `keyDecoder` als Typparameter (`a` und `value`) ein.

```Elm
map : (String -> Msg) -> Decoder String  -> Decoder Msg`
```

So liest sich der Aufruf nun:

`map` erwartet zwei Parameter:
1. Eine Funktion die aus einem `String` eine `Msg` erzeugt (`toKey`)
2. Ein Dekodierer der aus einem JSON Objekt einen `String` ausliest (`keyNameDecoder`)
Das Ergebnis ist ein `Decoder Msg` der aus einem JSON Objekt ein `Msg` Wert erzeugen kann.

Das wirft natürlich direkt die Frage auf wie wir Werte für Typen erzeugen die **mehr** als einen Parameter erwarten.
Dafür gibt es die Funktionen `map2` bis `map8`. Das Beispiel in der [Dokumentation](https://package.elm-lang.org/packages/elm/json/latest/Json-Decode#map2) für `map2` dekodiert einen `Point`-Wert der ein `x` und ein `y` erwartet.

```Elm
type alias Point = { x : Float, y : Float }

point : Decoder Point
point =
  map2 Point
    (field "x" float)
    (field "y" float)
```

Für komplexere Strukturen lohnt sich jedoch der Einsatz der [externen Bibliothek `elm-json-decode-pipeline`](https://package.elm-lang.org/packages/NoRedInk/elm-json-decode-pipeline/latest). Sie stellt alternative Kombinationsfunktionen zur Verfügung die die `mapN` Funktionen etwas eleganter ersetzen.

