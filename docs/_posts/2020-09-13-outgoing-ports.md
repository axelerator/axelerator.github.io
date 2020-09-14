---
layout: post
title:  "Ausgehende Ports"
date:   2020-09-13 21:26:23 -0400
ref: ports-outgoing
lang: de
permalink: /elm/outgoing-port-de
---

_Ports_ sind ein integraler Bestandteil von Elm. Bevor wir uns die konkrete Syntax anschauen, möchte ich gern mein eigenes Verständnis beschreiben


<p>Die offizielle Doku {% include sidenote.html content='<a href="https://guide.elm-lang.org/interop/ports.html">Offizielle Elm Doku zu Ports</a>' %}beschreibt Ports relativ knapp mit relative knapp</p>

> Ports erlauben Kommunikation zwischen Elm und JavaScript

Du fragts dich vielleicht: “Warum müssen wir mit JavaScript _kommunizieren_” oder denkst  “Elm _ist_ doch JavaScript wenn es ausgeführt wird!”

Ein Großteil der Freude an der Entwicklung mit Elm kommt von dem Ansatz schwierige Situation kategorisch auszuschließen. Dies erreicht Elm indem bestimmte syntaktische Konstrukte die gewisse Fehlerklassen erzeugen einfach nicht existieren. Vorallem: Anweisungen. In JavaScript an sich und vielen Bibliotheken sind Anweisungen allerdings ein essentieller Bestandteil der API.

<p>So sind ist zum Beispiel beim Aufruf der <code>setItem</code> {% include sidenote.html content="<a href='https://developer.mozilla.org/en-US/docs/Web/API/Storage/setItem'>API Doku zu localStorage.setItem</a>" %}"Funktion" zum Speichern im LocalStorage des Browser, nicht der Rückgabewert der Funktion sondern der Effekt auf den Speicher interessant.
</p>
Das steht im starken Kontrast zur _mathematischen_ Definition, wie sie in der funktionalen Programmierung verwendet wird. Bei einer _reinen_ Funktion kommt es _ausschließlich_ auf den Rückgabewert an.

Damit wir trotzdem mit der _unreinen_ Außenwelt (JavaScript) interagieren können bietet Elm das Konzept der _Ports_ an.
Es baut dem Konzept der Kommandos auf. Diese verkörpern im Prinzip Anweisungen in Elm: Sie lösen ein Verhalten aus haben aber kein Rückgabewert.

_Ports_ sind nunmehr das fehlende Bindeglied um diesen Teil von Elm mit der Außenwelt zu verbinden.
Ein _ausgehender_ Port sieht von der Elmseite aus wie ein _Kommando_ und wird wie folgt deklariert:

```elm
port sendMessage : String -> Cmd msg
```

Daraus können wir bereits einiges ableiten:

- `sendMessage` ist eine _Funktion_
- Aber es it eine spezielle _port_-Art von Funktion. Wir müssen sie nicht hier in Elm implementieren (schließlich wollen wir das ja auch in Javascript machen)
- Die Funktion hat ein Argument vom typ `string`
- Die Funktion gibt ein Kommando zurück - als etwas '_ausführbares'_ ohne Rückgabewert

Alles was jetzt noch fehlt ist die Implementierung im nativen JavaScript-Teil der Anwedung:

```javascript
var app = Elm.Main.init({
  node: document.querySelector('main')
});

app.ports.sendMessage.subscribe(
  function(data) { console.log(‘Launch missiles!’)}
);
```

Sobald wir auf der Elm-Seite einen Port deklarieren, erscheint auf der _ports_-Eigenschaft des "Anwendungsobjekts" eine neues Objekt. Für _ausgehende_ Ports können wir ein Callback anmelden, der von Elm mit dem aktuellen Werts des dor deklarierten Arguments aufegrufen wird.

Ich habe ein Repo mit einem ausführbaren Minimalbeispiel vorbereitet.


