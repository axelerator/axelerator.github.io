---
layout: post
title:  "Outgoing ports"
date:   2020-09-13 21:26:23 -0400
ref: ports-outgoing
lang: en
permalink: /elm/outgoing-port
---

Ports are an essential part of Elm. Before we look at the concrete syntax I just want to give my version of what they are.

<p>The official documentation {% include sidenote.html content='<a href="https://guide.elm-lang.org/interop/ports.html">Entry about ports in the official Elm docs</a>' %} is very terse about what ports are.</p>

> Ports allow communication between Elm and JavaScript.

“Why do we need to communicate with JavaScript?” You you might think, or “I thought Elm is JavaScript when executed anyway!”

Big parts of the joy of developing in Elm stem from its ability to “limit sad space”. A large class of errors is excluded by the language by syntactically excluding certain constructs from the language. Most notably: statements. A lot of JavaScript libraries and browser API however  are mostly statements. 

For example when calling the “function” to persist something in the local storage of the browser we’re not really interested in the return value but only with the effect it has on the browser. That is in stark contrast to pure functional programming, that favours expressions over statements.

To still be able to interact with this “dirty” imperative world outside of our Elm app, it offers the concept of ports.

It builds on the concept of commands, which basically already represent the concept of a statement: Trigger something without waiting/caring for the return value.

Ports are merely the missing link to connect this part of Elm with the outside world.
A port that triggers a statement in JavaScript is often called an _outgoing_ port. And we can see now how the signature describes directly it’s purpose:

```elm
port sendMessage : String -> Cmd msg
```

From this declaration we can drive the following:

- sendMessage is a function
- But it’s a special “port” kind of function, so we will not have to implement it ( since we want to define *outside* of Elm, in JavaScript what happens)
- The function takes one argument of type String
- The return value is a Command - so this is basically saying: “I did the thing but I can’t return you a value”

All that is missing is to define what JavaScript function is executed when we ask the Elm app to issue our command:

```javascript
var app = Elm.Main.init({
  node: document.querySelector('main')
});

app.ports.sendMessage.subscribe(
  function(data) { console.log(‘Launch missiles!’)}
);
```

As soon as we declare a port in Elm it will expose a new object on the ports property of the application object. For outgoing ports we can subscribe a callback that will be executed when our command on the elm page is issued.

I prepared a minimal example without any dependencies for you to see how everything plays together, consisting only of those two files:

