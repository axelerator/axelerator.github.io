---
layout: post
title:  "Bauen im Freien"
date:   2022-10-19 18:00:00 -0400
ref: building-in-the-open
lang: de
permalink: /business/de/building-in-the-open
---

<img src="/assets/posts/building-in-the-open/features.svg" width="130" height="130" style="float:right; margin: 5px 10px 10px 0"/>
Begleite mich wie ich meinen _digitalen Aktenschrank_ und mein 1-Mann-Startup darum in der Öffentlichkeit baue.
Mit langjähriged Erfahrungen in der Softwareentwicklung strebe ich an, eine Lösung zu schaffen, die die Lücke zwischen Bequemlichkeit und Datensicherheit schließt,
während ich jeden Schritt des Prozesses mit Dir teile.

Verfolge Livecoding Sessions, Erkenntnisse und die Möglichkeit, ein Produkt mitzugestalten, das für Einzelpersonen,
Familien und KMUs gleichermaßen konzipiert ist.

---

Content:

  - [Intro](#intro)
  - [Für wen?](#who)
  - [Das wird gebaut](#usp)
  - [If you build it, ~~they will come~~ nobody cares](#building) 

---

<a name="intro" />

{% capture note_content %}
    ![Selfhtml.de in 1998](/assets/posts/building-in-the-open/selfhtml.jpg)<br>
    Screenshot of SelfHtml.de from 1998 taken with the 
    [WaybackMachine](https://web.archive.org/web/20000915151937/http://www.netzwelt.com/selfhtml/tcab.htm)
{% endcapture %}
Ich habe mit der Webentwicklung im letzten Jahrtausend begonnen,
und zwar mit Hilfe einer Website namens {% include marginnote.html id="selfhtml" content=note_content  %} [SELFHTML](https://wiki.selfhtml.org/) im Jahr 1998.

Fast ein Jahrzehnt lang habe ich in Deutschland gemeinsam mit zwei Freunden mein eigenes [Softwareunternehmen]((https://www.fortytools.com/)) geführt.
Vor fünf Jahren bin ich dann nach Kanada gezogen, 
um bei Shopify zu arbeiten. 
Derzeit genieße ich etwas Freizeit zwischen den Jobs und möchte diese Monate nutzen,
um als Solo-Unternehmer ein Produkt/Geschäft aufzubauen - eine Idee, über die ich seit fast zehn Jahren nachdenke.

Hier ist das Problem, das ich mit meiner Software lösen möchte:
{% capture note_content %}
    <img src="/assets/posts/building-in-the-open/unread.svg" style="width: 5em" alt="Mail logo mit einer hohen Anzahl ungelesener E-Mails">
{% endcapture %}
{% include marginnote.html id="unread" content=note_content  %}

> De bekommst eine Benachrichtigung über eine neue E-Mail. Du öffnest sie und erkennst sofort, 
> dass sie wichtig ist und Du darauf reagieren musst.
> 
> Aber Du hast jetzt keine Zeit dafür.
>
> Also läst Du sie als ungelesen markiert.

Mir geht es mit physischer Post genauso – und es ist ein Albtraum. 
Ich habe Stapel ungeöffneter Briefe in meiner Wohnung.
Einige davon sind dringend, andere wichtig, manche beides, manche keins von beidem.

Und dann kommt der gefürchtete Moment, in dem ich diesen **einen** Brief finden muss.

Ich konnte mich nie für eine bestehende Software entscheiden, 
weil dies heutzutage höchstwahrscheinlich bedeutet, dass ich einem Cloud-Software-Anbieter 
ein sehr vollständiges Bild meines persönlichen Lebens geben muss. 
 
Dazu kommt:

- ich muss einen monatlichen Beitrag zahlen um weiter auf meine Daten zugreifen zu können
- der Anbieter verkauft Teile meiner Daten für zusätzlichen Profit
- der Anbieter teilt Daten großzügig mit Behörden im In- und Ausland
- der Anbieter wird Ziel eines Hackerangriffs und meine Daten gelangen in die Hände Unbefugter

{% capture note_content %}
    <img src="/assets/posts/building-in-the-open/paperless.png" style="width: 5em" alt="Mail logo indicating a lot of unreal e-mails"><br>
    [Paperless](https://github.com/paperless-ngx/paperless-ngx) ist eine selbst gehostete Dokumenten Management Lösung.
{% endcapture %}

While there are alternatives like _Paperless_  it is only accessible to people who are already well versed in
hosting their own servers.

Es gibt zwar Open-Source Alternativen wie {% include marginnote.html id="paperless" content=note_content  %} _Paperless_,
diese sind aber häufig nur für Leute zugänglich die sich im Betrieb von Server auskennen.

Ich möchte dieses Problem für mich selbst sowie für technisch weniger versierte Personen lösen.
Es ist immer ein Kompromiss zwischen Benutzerfreundlichkeit, Datenschutz und Betriebskosten. 
Mein Ziel ist es eine Software entwickeln, die es den Benutzern ermöglicht, einen Kompromiss zu wählen,
der ihren Bedürfnissen entspricht, und im Laufe der Zeit ihre Meinung zu ändern.

### <a name="who" /> Für wen?

Ich habe mit vielen Freunden und Familienmitgliedern gesprochen,
und die meisten haben ähnliche Probleme mit der Dokumentenverwaltung.
Und sobald man eine Familie gründet kommt eine Menge an wichtiger Post steigt,
, die man im Namen seiner Kinder verwalten muss dazu.


{% capture note_content %}
[MVP](https://de.wikipedia.org/wiki/Minimum_Viable_Product) steht für _"Minimum Viable Product"_
{% endcapture %}

Der {% include marginnote.html id="mvp-def" content=note_content %} MVP, den ich zu Beginn entwickeln werde,
wird sich also auf Einzelpersonen konzentrieren, aber ein Multiuser-Konzept wird Teil des Software-Designs sein.


{% capture note_content %}
[KMU](https://de.wikipedia.org/wiki/Kleine_und_mittlere_Unternehmen) steht für r _"Kleine und mittlere Unternehmen"_
{% endcapture %}

In gewissem Maße könnte eine Lösung dieses Problems sogar auf {% include marginnote.html id="sme-def" content=note_content %}KMU angewendet werden.
Zum Beispiel waren wir bei Fortytools zwischen 15-20 Personen und hatten mit unserem 
eigenen Produkt und Entwicklungsarbeit für andere Unternehmen viel zu tun. 
Wir hatten genug Papierkram zu erledigen, um jemanden einzustellen. 
Dokumente mussten oft abgerufen, verarbeitet und mit anderen Benutzern geteilt werden.

### <a name="usp" /> This is what I'm building

Das Herzstück der Software, die ich entwickeln werde,
lässt sich am besten als digitales Aktenschrank beschreiben.
Das ist an sich nichts Neues, aber ich war überrascht,
wie wenige Lösungen es gibt, die meinen persönlichen Anforderungen an eine solche Lösung nicht gerecht werden.

"Datenschutz" ist ein Feature in jeder Software, aber normalerweise nicht eines über das irgendjemand aufgeregt ist.

Bis jemand Zugriff auf Daten erhält, der das nicht sollte. 
Und das passiert viel häufiger, als man denkt!

![Datatenpannen 2023](/assets/posts/building-in-the-open/breaches23.svg)


{% capture note_content %}
[SaaS](https://en.wikipedia.org/wiki/Software_as_a_service) Software und die bei einem externen IT-Dienstleister betrieben und vom Kunden als Dienstleistung genutzt werden kann.
{% endcapture %}

Deine Daten einem SaaS {% include marginnote.html id="saas-def" content=note_content %} Anbieter zu geben, ist sicherlich am bequemsten.
Dort sind sie vermutlich auch besser gegen Verlust geschützt als sich auf manuelle Backups zu verlassen.

Allerdings sind nicht alle SaaS-Anbieter gleich aufgestellt und es gibt jedes Jahr viele Datenverletzungen. 
Größere Unternehmen sind in der Regel gut darin, Ihre Daten vor unbefugtem Zugriff zu schützen. 
Bei günstigen Lösungen, zum Beispiel Google Drive, wird der Anbieter Deine Daten auf die eine oder andere Weise nutzen, 
um ihr Projekt zu monetarisieren. Ja, sie werden in Deine Dateien schauen. 
Wenn Du zum Beispiel eine Tabelle in Google Sheets zum Vergleich für Kinderwagen hast, 
wurst Du in den nächsten Tagen Werbung für Babyprodukte erhalten.

Ich werde in meiner Lösung den Datenschutz zu einem zentralen Anliegen machen und 
es ermöglichen, die Software ohne jegliche Internetverbindung zu betreiben. 

Aber ich möchte auch, dass die Software so zugänglich wie möglich ist. 
Daher werde ich die Software in verschiedenen Varianten anbieten, die es ermöglichen, 
den perfekten Mittelweg zwischen Datenschutz und Komfort zu wählen.

<div id="variants"></div>

Am wichtigsten für dieses Modell ist, dass es **einfach** ist zwischen diesen **Varianten zu wechseln**.
Der Kernidee dieses zu ermöglichen ist alle Informationen in einfachen Dateien zu speichern anstatt auf 
eine Datenbank zu setzen.

Diese Dateien werden nach einem einfachen Schema (Jahr/Monat) in Ordern abgelegt. Diese ermöglichtes Dokumente
wiederzufinden selbst wenn man aufgehört hat meine Anwendung zu benutzen.


<div id="features"></div>

### <a name="building" /> If you build it, ~~they will come~~ nobody cares

Heißt so viel wie

> Wenn du es baust,
> ~~werden sie schon kommen~~
>
> interessiert es kein Schwein.


Es spiegelt die, besonderns bei Entwicklern verbreitete, Idee wider, dass man lediglich ein gutes Produkt bauen muss und es
sich dann schon rumspricht. Eine anderer Versuchung ist es das Produkt vor der Veröffentlichung zu perfektionieren, um
mit einem _"Big Bang"_ zu starten.

Die Realität ist aber, dass das für die Mehrheit der digitalen Produkte nicht ausreicht. 
Deswegen habe ich beschlossen meine Produkt von Anfang an ind der Öffentlichkeit zu bauen.

Praktisch heißt das, dass ich regelmäßig live auf Twitch programmieren und dabei gerne auch Fragen beantworten werde. 
Aber da das für viele nicht besonder spannend ist werde ich auch noch andere Wege erforschen meine Erfahrungen
im Aufbau dieses Ein-Mann-Unternehmens zu teilen (mehr Blog-Artikel, Instragram, Youtube, Podcasts?).

Falls sich das für dich spannend anhört freue ich mich wenn du dich für meinen wöchentlichen Newsletter einträgst.

<div id="subscribe"></div>

<link rel="stylesheet" href="/assets/interactive/styles.css">
<script src="/assets/interactive/interactive.js"></script>
<script>
  var variants = Elm.Interactive.init({
    node: document.getElementById('variants'),
    flags: { kind: "Variants", lang: "de" }
  });

  var features = Elm.Interactive.init({
    node: document.getElementById('features'),
    flags: { kind: "Features", lang: "de"  }
  });

  var subscribe = Elm.Interactive.init({
    node: document.getElementById('subscribe'),
    flags: { kind: "Subscribe" }
  });
</script>
