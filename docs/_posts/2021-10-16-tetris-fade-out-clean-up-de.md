---
layout: post
title:  "Episode 12 & 13: Ausblenden und Aufräumen"
date:   2021-10-16 18:00:00 -0400
ref: tetris-fade-out
lang: de
permalink: /elm/de/tetris-fade-out
---

<img src="/assets/posts/tetris-fade-out/fade.gif" style="float:left; margin: 5px 10px 10px 0"/>
In [Episode 12(1h:25m)](https://www.youtube.com/watch?v=7HhOdCNfEj4) habe ich zunächst einen einfachen Zähler für die entfernten Reihen gebaut. Das graduelle Ausblenden ist zu einen Cliffhanger geworden, da ich dort einen Fehler eingebaut hab, den ich erst in [Episode 13 (1h:20)](https://www.youtube.com/watch?v=OfNkjrJGtyc) auflöse. Das nehme ich zum Anlass den Code mit Hilfe des großartigen [*Conquer of Completion*](https://github.com/neoclide/coc.nvim) etwas aufzuräumen.

Für Episode 12 habe ich wie bisher einen einzelnen [Commit](https://github.com/axelerator/elm-tetris/commit/bcb5e904ecdc7127bb379a836ecfdf874d1552f6) erzeugt und einen [Branch](https://github.com/axelerator/elm-tetris/tree/episode12) der den Code am Ende der Episode enthält.

Die Codeänderungen für Episode 13 habe ich etwas anders organisiert. Da ich den Code großzügig umorganisiert habe betreffen die Änderungen viele Zeilen.
Damit die Git Historie trotzdem übersichtlich bleibt habe ich mehrere kleine Commits erzeugt.
Es gibt natürlich trotzdem einen [`episode13` Branch](https://github.com/axelerator/elm-tetris/tree/episode13) der den Endzustand enthält. Die Entwicklung zwischen den Episoden 12 und 13 habe ich aber diesmal in einem [**Pull-Request**](https://github.com/axelerator/elm-tetris/pull/1/commits) zusammengefasst.

<iframe width="560" height="315" src="https://www.youtube.com/embed/7HhOdCNfEj4" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

<iframe width="560" height="315" src="https://www.youtube.com/embed/OfNkjrJGtyc" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

---

Inhalt:

  - [Punktestand](#scoring)
  - [Ausblenden](#fading)
  - [Aufräumen](#cleanup)

---


### <a name="scoring" /> Punktestand

Um sich vergleichen zu können habe ich dem Spiel einen [Typen `Score` für den Punktestand](https://github.com/axelerator/elm-tetris/commit/bcb5e904ecdc7127bb379a836ecfdf874d1552f6#diff-2dd82f159d96fbfcd26fb7d885d25e0d54efde9e19a42494b416fa84a5aca568R39) hinzugefügt.
Ich habe die einfachst mögliche Implementierung gewählt: 1 Zeile = 1 Punkt. Das echte Punktesystem von Tetris is um einiges komplizierter (Quelle: [Tetris Wiki](https://tetris.fandom.com/wiki/Scoring))


| Level |Points for 1 line | 2 lines | 3 lines | 4 lines |
|:-----:|:----------------:|:-------:|:-------:|:-------:|
|0 | 40 | 100 | 300 | 1200 |
|1 | 80 | 200 | 600 | 2400 |
|2 | 120 | 300 | 900 | 3600 |
|9 | 400 | 1000 | 3000 | 12000 |

`level(n) =  40 * (n + 1) 100 * (n + 1) 300 * (n + 1) 1200 * (n + 1)`

---

### <a name="fading" /> Ausblenden

Für das Ausblenden habe ich eine [neue 'Zeilenvariante' hinzugefügt](https://github.com/axelerator/elm-tetris/commit/bcb5e904ecdc7127bb379a836ecfdf874d1552f6#diff-2dd82f159d96fbfcd26fb7d885d25e0d54efde9e19a42494b416fa84a5aca568R82):

```Elm
type Row
    = Row (List Field)
    | FadingRow (List Field) Opacity
```

Die `FadingRow` stellt eine Zeile dar die logisch entfernt wurde aber visuell noch teilweise sichtbar ist.
Neben den einzelnen Spalten enthält sie auch einen Transparenzwert.
Um das Ausblenden in einer optisch ansprechenden Geschwindigkeit zu erreichen feuern wir jetzt unseren `GravityTick` alle [*30* anstatt *100* Millisekunden](https://github.com/axelerator/elm-tetris/commit/bcb5e904ecdc7127bb379a836ecfdf874d1552f6#diff-2dd82f159d96fbfcd26fb7d885d25e0d54efde9e19a42494b416fa84a5aca568R548) und erhöhen die Transparenz der 'ausblendenden' Reihen bei jedem Tick mit der [`progressFading` Funktion](https://github.com/axelerator/elm-tetris/commit/bcb5e904ecdc7127bb379a836ecfdf874d1552f6#diff-2dd82f159d96fbfcd26fb7d885d25e0d54efde9e19a42494b416fa84a5aca568R462).

Bei dem Versuch `progressFading` an all den richtigen Stellen aufzurufen habe ich dann auch den Fehler eingebaut. Als Teil von `eraseCompleteRows` habe ich [das aktuelle Teil zurückgesetzt](https://github.com/axelerator/elm-tetris/commit/bcb5e904ecdc7127bb379a836ecfdf874d1552f6#diff-2dd82f159d96fbfcd26fb7d885d25e0d54efde9e19a42494b416fa84a5aca568R531).
Der [erste Commit](https://github.com/axelerator/elm-tetris/commit/4bac5a1f167b593b9f949ff66a8868b8f7c5e5b2) von Episode 13 behebt diesen Fehler und alles funktioniert wie erwartet.

---

### <a name="cleanup" /> Aufräumen

Den Rest dieser Episode verbringe ich damit die allgemeine Anwendungslogik von der 'reinen' Spiellogik zu trennen. Ich würde es allerdings noch nicht als eine Rafaktorisierung bezeichnen denn die Änderungen sind alle recht 'mechanisch'. Damit meine ich, dass die Funktionen sich fast nicht geändert haben sondern lediglich den Ort gewechselt haben wo sie gespeichert sind.

Dabei habe ich mir ein neues Werkzeug in meiner Entwicklungsumgebung zu Nutze gemacht. [Conquer of Completion](https://github.com/neoclide/coc.nvim) kur *CoC* ist ein Vim Plugin, dass das [Language Server Protocol](https://microsoft.github.io/language-server-protocol/overviews/lsp/overview/) nutzt um den Entwickler mit Sprachspezifischen Hinweisen zu unterstützen. Es ist das gleiche Protokoll das auch in VS Code für viele Sprachen verwendet wird um Autovervollständigung und andere Funktionen wie das Organisieren von Imports zu unterstützen.

Mit Hilfe des *CoC* lassen sich Operationen wie das Verschieben von Funktionen deutlich effizienter ausführen, da das Plugin lästige Tätigkeiten, wie das importieren von Modulen und entfernen von ungenutztem Code automatisiert.

Ein paar entscheidende Hinweise wie dieses Setup einzurichten ist habe ich in dem Projekt für den [Elm Language Server](https://github.com/elm-tooling/elm-language-server) gefunden.

Ich denke ich werde in naher Zukunft nochmal eine dedizierte Episode zur Einrichtung eine Elm Entwicklungsumgebung machen.






