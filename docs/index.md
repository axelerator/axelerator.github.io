---
layout: default
title: Hi!
ref: home
lang: en
tags: elm
---

I'm building a digital filing cabinet to order the chaos in my (and potentially your life).
Whether you're a companion in struggling with staying on top of letters and e-mails or a fellow
developer curious how this adventure unrolls, this is the place where I will regularly share my
progress and learning, both form a technical as well as a business perspective.


## Posts
{% assign posts=site.posts | where:"lang", page.lang %}
{% for post in posts %}
  <section>
    <h3><a href="{{ post.url }}">{{ post.title }}</a></h3>
    <p class="post-meta">published: {{ post.date | date: '%B %d, %Y' }}</p>
    {{ post.excerpt }}
  </section>
  <hr />
{% endfor %}
