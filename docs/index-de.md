---
layout: default
title: Moin!
lang: de
ref: home
permalink: /de
---
Einmal im Jahr werde ich daran erinnert, dass ich immernoch diese Domain bezahle.
Nach einer guten Dekade habe ich nun endlich was gefunden worüber ich schreiben kann.

Ich starte erstmal mit eine Artikelserie über Elm - meine derzeitige Lieblingssprache zum Nebenbeicoden. Aber mit der Zeit werde ich vermutlich auch noch zu anderen Themen herumschwafeln 😅.


## Neueste Beiträge
{% assign posts=site.posts | where:"lang", page.lang %}
{% for post in posts %}
  <h3>
    <div><a href="{{ post.url }}">{{ post.title }}</a></div>
    <div class="post-date">{{ post.date | date: '%B %d, %Y' }}</div>
  </h3>
  {{ post.excerpt }}
  <a href="{{ post.url }}">more..</a>
{% endfor %}
