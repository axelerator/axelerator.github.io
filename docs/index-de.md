---
layout: default
title: Moin!
lang: de
ref: home
permalink: /de
tags: elm
---

Ich baue einen digitalen Aktenschrank als 1-Mann-Startup um mein (und potenziell Dein)
Dokumentendurcheinander zu ordnen.

Wenn du ein Leidensgenosse im Kampf gegen das Dokumentenchaos bist oder neugiereig wie
es ist ein Startup als Solo-entwickler auf die Beine zu stellen kannst du hier regelmäßig
Erfahrungsberichte lesen. Sowohl von der technischen als auch der Businessperspektive.

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
