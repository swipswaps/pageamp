PageAmp is a ground breaking server-side tool for web developers. It [makes HTML reactive](https://github.com/ubimate/pageamp/wiki/White-Paper) and it's designed to work in a standard [LAMP environment](https://en.wikipedia.org/wiki/LAMP_(software_bundle)). You'll be surprised at how simple and effective reactive HTML can be.

It allows you to:

1. add reactive logic to plain HTML that works the same in both the server and the client
2. make pages ready for search engine indexing and still fully dynamic in the browser
3. modularise your source code and bring it all together with the <:import> tag
4. separate content and markup, as well as to access and implement local and remote services
5. define common blocks as custom tags, keeping your code [DRY](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself)
6. turn blocks into easily reusable components and leverage PageAmp's [Page Kit](http://devel.ubimate.com/).

[See it in action](http://pageamp.org/#see-it-in-action)

[Read the white paper](https://github.com/ubimate/pageamp/wiki/White-Paper)

## How it works

1. It extends HTML: its additions are marked with `:` in tag and attribute names and wrapped in `${}` in texts and attributes.
2. It works in the server: once you copy its `.pageamp/`, `index.php` and `.htaccess` to a LAMP server, it will handle page requests and execute application logic at page delivery.
3. It works in the client: the output will be a standard and complete HTML page, but will also include application state and code so capable clients can take over application execution.

## How it compares

1. Reactive JS frameworks: the latest trend in web development, and yet, born for the client only. [React](https://reactjs.org/) and [Vue.js](https://vuejs.org/) are great, but:
   * server-side rendering is bit of a gimmick, and how many projects are you actually [hosting on NodeJS](https://w3techs.com/technologies/overview/programming_language/all) anyway?
   * they override the declarative HTML with the procedural JavaScript — only to then having to mitigate that with yet another language like [JSX](https://reactjs.org/docs/introducing-jsx.html)
   * PageAmp keeps it straight by making HTML reactive itself, and it works in the server out of the box.
2. Server-side templating: each server technology has its own set, but none can make the client an integral part of their design:
   * in most, output pages are static by design: adding dynamic behaviour and, crucially, keeping it coherent when they change is a job in itself
   * the few that provide companion client-side components don't let you easily customize them or add your own
   * PageAmp cancels the client/server divide making real, customizable client/server components natural to write.
