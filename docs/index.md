---
layout: default
title: Hi!
ref: home
lang: en
---

Once per year I get reminded that I still pay for this domain. It's been a decade since there was some content here and I finally have something to write about.

So for now I am starting a series about Elm, my current favorite language to play around in. But with time I might use this space to share ramblings about other areas of interes as well 😅

## Latest posts
{% assign posts=site.posts | where:"lang", page.lang %}
{% for post in posts %}
  <h3>
    <div><a href="{{ post.url }}">{{ post.title }}</a></div>
    <div class="post-date">{{ post.date | date: '%B %d, %Y' }}</div>
  </h3>
  {{ post.excerpt }}
  <a href="{{ post.url }}">more..</a>
{% endfor %}
