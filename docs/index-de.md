---
layout: default
title: Moin!
lang: de
ref: home
permalink: /de
---

Willkommen auf meinem Blog, wo ich zurzeit meine Shownotizen zu meinem [wöchentlichen Livecoding Stream](https://www.twitch.tv/programmingisfun) veröffentliche.

Inspiriert von [Shaun Lebrons ClojureScript Implementierung](https://shaunlebron.github.io/t3tr0s-slides/#0) versuche ich vrzuführen wie anmutent die Anwedungsentwicklung mit Elm ist.
Du bist in der Zielgruppe wenn Du schon mit anderen Sprachen/Frameworks Webanwendungen entwickelt hast. Besondere Kenntnis von JavaScript oder der Browser API ist allerdings nicht nötig.

Ich versuche die Episoden zwischen 30 und 90 Minuten zu halten. Anschließend veröffenltiche ich hier dann einen Artikel pro Episode indem ich auf ein paar Konzepte näher eingehe mit denen Entwickler aus weniger 'funktionalem Umfeld' vielleicht nicht so vertraut sind.

## Neueste Beiträge
{% assign posts=site.posts | where:"lang", page.lang %}
{% for post in posts %}
  <h3>
    <div><a href="{{ post.url }}">{{ post.title }}</a></div>
    <div class="post-date">{{ post.date | date: '%B %d, %Y' }}</div>
  </h3>
  {{ post.excerpt }}
  <hr />
{% endfor %}
