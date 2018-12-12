[homepage](http://pageamp.org)

## What it is

PageAmp is a ground breaking server-side tool for web developers. It [makes HTML reactive](https://github.com/ubimate/pageamp/wiki/White-Paper#reactivity) and it's designed to work in a standard [LAMP environment](https://en.wikipedia.org/wiki/LAMP_(software_bundle)). You'll be surprised at how simple and effective reactive HTML can be.

It allows you to:

1. add reactive logic to plain HTML that works the same in both the server and the client
2. make pages [ready for search engine indexing and still fully dynamic in the browser](https://github.com/ubimate/pageamp/wiki/White-Paper#isomorphism)
3. modularise your source code and bring it all together with the [<:import>](https://github.com/ubimate/pageamp/wiki/White-Paper#isomorphism) tag
4. [separate content and markup](https://github.com/ubimate/pageamp/wiki/White-Paper#data-binding), as well as to access and implement local and remote services
5. define common blocks as [custom tags](https://github.com/ubimate/pageamp/wiki/White-Paper#custom-tags), keeping your code [DRY](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself)
6. turn blocks into proper [HTML components](https://github.com/ubimate/pageamp/wiki/White-Paper#components) and leverage PageAmp's [Page Kit](http://devel.ubimate.com/).

[See it in action](http://pageamp.org/#see-it-in-action)

[Read the white paper](https://github.com/ubimate/pageamp/wiki/White-Paper)

[Development Kanban board](https://trello.com/b/aULGQZAd)

## How it works

1. **it extends HTML**: its additions are marked with `:` in tag and attribute names and wrapped in `${}` in texts and attributes
2. **it works in the server**: once you copy its `.pageamp/`, `index.php` and `.htaccess` to a LAMP server, it will handle page requests and execute application logic at page delivery
3. **it works in the client**: the output will be a standard and complete HTML page, but will also include application state and code so capable clients can take over application execution.

## How it compares

1. **reactive JS frameworks**: the latest trend in web development, and yet, born for the client only. [React](https://reactjs.org/) and [Vue.js](https://vuejs.org/) are great, but:

   * server-side rendering is bit of a gimmick, and how many projects are you actually [hosting on NodeJS](https://w3techs.com/technologies/overview/programming_language/all) anyway?
   * they override the declarative HTML with the procedural JavaScript — only to then having to mitigate that with yet another language like [JSX](https://reactjs.org/docs/introducing-jsx.html)

> PageAmp keeps it straight by making HTML reactive itself, and it works in the server out of the box

2. **server-side templating**: each server technology has its own set, but none can make the client an integral part of their design:

   * in most, output pages are static by design: adding dynamic behaviour and, crucially, keeping it coherent when they change is a job in itself
   * the few that provide companion client-side components don't let you easily customize them or add your own

> PageAmp cancels the client/server divide making real, customizable client/server components natural to write
