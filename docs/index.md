---
layout: default
title: Hi!
ref: home
lang: en
tags: elm
---

Welcome to my blog where I'm currently publishing the show notes to my weekly [livecoding stream on twitch - every Wednesday 7pm (EST)](https://www.twitch.tv/programmingisfun).

Inspired by [Shaun Lebrons ClojureScript implementation](https://shaunlebron.github.io/t3tr0s-slides/#0) I'm trying to showcase the beauty that webdevelopment in the Elm programming language is.
The audience are developers that may have experience with other languages or frameworks for webdevelopment already. Although no particular familiarity with JavaScript or the browser API is needed.

I'm trying to keep episodes between 30 and 90 minutes. After recording each episode I'm publishing a little write-up here where I go into detail about some concepts that developers with a less functional background might have questions about.

## Latest posts
{% assign posts=site.posts | where:"lang", page.lang %}
{% for post in posts %}
  <section>
    <h3><a href="{{ post.url }}">{{ post.title }}</a></h3>
    <p class="post-meta">published: {{ post.date | date: '%B %d, %Y' }}</p>
    {{ post.excerpt }}
  </section>
  <hr />
{% endfor %}
