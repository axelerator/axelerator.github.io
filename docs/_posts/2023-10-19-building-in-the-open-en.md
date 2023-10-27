---
layout: post
title:  "Building in the open"
date:   2022-10-19 18:00:00 -0400
ref: building-in-the-open
lang: en
permalink: /business/en/building-in-the-open
tags: solopreneur business
---

---

Content:

  - [Intro](#intro)
  - [Who is this for?](#who)
  - [This is what I'm building](#usp)
  - [If you build it, ~~they will come~~ nobody cares](#building) 
  - [Intro](#intro)

---

### <a name="intro" /> Hi 👋


I started web development in the last millennium with the help of a website called [SELFHTML](https://wiki.selfhtml.org/)

{% capture snote_content %}
[This](https://web.archive.org/web/20000915151937/http://www.netzwelt.com/selfhtml/tcab.htm)
is how it looked back then. 
{% endcapture %}
{% include marginnote.html id="selfhtml" content=snote_content start_open=true %}
![Selfhtml.de in 1998](/assets/posts/building-in-the-open/selfhtml.jpg)

I ran my own [software company](https://www.fortytools.com/) with two friends in Germany for nearly a decade. 
And then, five years ago, after I moved to Canada to work for Shopify.
I'm currently enjoying some free time between jobs and want to use these months to 
spin up a product/business as a solo entrepreneur with an idea I've been thinking about for nearly ten years.

Here is the problem I want to address, you know that situation: You get a notification about an e-mail. You know it's important. You have to **act** on it, but you don't have the time to do it now.
So you leave it marked as _unread_.

I do this with physical mail. And it is a nightmare. I end up with stacks of unopened letters scattered through my apartment. Some of them urgent, some of them
important, some of them both some of them none of it.

And then comes the dreaded moment where I have to find that **one letter**.

I never committed to an existing software because these days this most likely means I have to give a very complete picture of my personal life to a cloud
software profile that 

- will only give me access to my data as long as I pay them a monthly fee
- will potentially use/sell my data
- give government(s) agencies access to them
- loose them

While there are alternatives like [paperless](https://github.com/paperless-ngx/paperless-ngx) it is only accessible to people who are already well versed in
hosting their own servers.

I want to solve this problem for myself as well as non-technical people. Hitting the right spot between ease-of-use, level of privacy and cost to operate is 
always an trade off based on ones current situation. Knowing this I will be building a software that allows users to choose a compromise that suits _their_ needs
and change their mind over time.

### <a name="who" /> Who is this for?

I've talked to a lot of friends and family and a lot of people struggle with _document management_ in similar ways. Not surprisingly the amount of important 
mail multiplies once you start a family and you receive documents that you have to manage on behalf of your children.

{% capture note_content %}
_"Minimum Viable Product"_([MVP](https://en.wikipedia.org/wiki/Minimum_viable_product))
{% endcapture %}
{% include marginnote.html id="mvp-def" content=content%}
So while the _MVP_ that I will build in the beginning
will focus on individuals a **multiuser** concept will be part of the foundations software design.

To some degree a solution of this problem could be even applied to Small and medium-sized enterprises ([SME](https://en.wikipedia.org/wiki/Small_and_medium-sized_enterprises)).
For example at Fortytools we were between 15-20 people and had a lot going on between our own SaaS and our contracting business. We had enough _paperwork_ to deal
with to employ someone. And documents often had to retrieved, processed and shared with other users.

### <a name="usp" /> This is what I'm building

The core of the software I am going to build can best be described as a digital filing cabinet. That in itself is not especially novel, but I was surprised at
how few solutions there are that do not satisfy my personal requirements for such a solution.

{% capture note_content %}
![data breaches](/assets/posts/building-in-the-open/breaches23.svg)
{% endcapture %}

_"Data privacy"_ is the least interesting feature in any software until someone 
gets access to you data who is not supposed to.{% include marginnote.html id="breach-stats" content=note_content start_open=true %} Which happens a lot more often than you think!
Leaving data with you Saas provider is certainly the most convenient. It's also arguably likely to loose your data when you rely
on the backup tools of a cloud provider than managing external disks and thumb drives.

However not all cloud providers are set up equally and there are a lot of data breaches each year. Larger companies are usually good
at protecting your data against unauthorized access. However if your are _not_ paying a significant price tag, for example for Google Drive,
the provider will use your data in one way or another to monetize their project. Yes they will look **into** files. If you create
a comparison Google Sheet for Baby strollers, you **will** get ads of baby products.

So I want to make **privacy** a major concern and allow you to run the software without any connection to the internet.
**But** I also want to make the software as easily accessible as possible.
So I will launch the software in different _variants_ that allows you to pick your sweet sweet spot between _privacy_ and _comfort_. 
<div id="variants"></div>

And most importantly I will make it **easy to switch** between these. One of the main technical ingredients to achieve this is to store
everything in _files_. Documents will be stored _by year_ and _by month_. An extremely simple scheme that will be manageable even if you
stop using the software altogether.

<div id="features"></div>

### <a name="building" /> If you build it, ~~they will come~~ nobody cares

There is this platitude about how it's not enough to just build a good product.
The gist is that you should start starting marketing & sales activities as soon as you start building.

And the reason this is still being told is that especially solo developers are likely to fall into this trap.
There is a high temptation wanting the first release to be perfect, wanting to add just one more feature..
Another catalyst for this line of thinking/feeling is that it's better to start with a "big bang". 

It's been proven over and over again that this is **not** the case.
So to avoid falling into this trap I decided to **"build in the open"** from the start.

Practically that means I'm going to stream live on Twitch as I write the first lines of code.
I'll be happy to answer questions and will be talking in more detail about some of technical
decisions for this project.

Watching live coding sessions is not always most captivating and I also want to share non-technical challenges
along the way. So I will also build other channels (more blog posts Instagram, Youtube, Podcast, Newsletter). I'm also 
interested in learning from other peoples journey.

So if you're interested in following my journey I'd love to send you my weekly newsletter where I share recent progress.

<div id="subscribe"></div>

<link rel="stylesheet" href="/assets/interactive/styles.css">
<script src="/assets/interactive/interactive.js"></script>
<script>
  var variants = Elm.Interactive.init({
    node: document.getElementById('variants'),
    flags: { kind: "Variants" }
  });

  var features = Elm.Interactive.init({
    node: document.getElementById('features'),
    flags: { kind: "Features" }
  });

  var subscribe = Elm.Interactive.init({
    node: document.getElementById('subscribe'),
    flags: { kind: "Subscribe" }
  });
</script>
