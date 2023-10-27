---
layout: default
title: Tags
ref: tags
lang: en
permalink: /tags/
tags: elm
---

{% for tag in site.tags %}
  <a name="{{tag[0]}}"></a>
  <h2 id="{{tag[0]}}" >
    Posts tagged with <a href="#{{tag[0]}}">#{{tag[0]}}</a> 
  </h2>
  <ul>
    {% assign posts_in_lang = tag[1] | where: 'lang', 'en' %} 
    {% for post in posts_in_lang %}
    <li>
        <a href="{{ post.url }}">{{ post.title }}</a>
    </li>
    {% endfor %}
  </ul>
{% endfor %}
