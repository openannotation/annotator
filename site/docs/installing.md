# Installing

Annotator is a JavaScript library, and there are two main approaches to
using it. You can either use the standalone packaged files, or you can
install it from the [npm](https://www.npmjs.com/) package repository and
integrate the source code into your own
[browserify](http://browserify.org/) or
[webpack](https://webpack.github.io/) toolchain.

## Built packages

`Releases <releases>` are published on `our GitHub repository <>`. The
released zip file will contain minified, production-ready JavaScript
files that you can include in your application.

To load Annotator with the default set of components, place the
following `<script>` tag towards the bottom of the document `<body>`:

``` html
<script src="annotator.min.js"></script>
```

## npm package

We also publish an `annotator` package to npm. This package is not
particularly useful in a Node.js context, but can be used by
[browserify](http://browserify.org/) or
[webpack](https://webpack.github.io/). Please see the documentation for
these packages for more information on using them.
