
About
-----

_jQuery-i18n_ is a jQuery plugin for doing client-side translations in javascript. It is based heavily on [javascript i18n that almost doesn't suck](http://markos.gaivo.net/blog/?p=100) by Marko Samastur, and is licensed under the [MIT license](http://www.opensource.org/licenses/mit-license.php).

Installation
------------

You'll need to download the [jQuery library](http://docs.jquery.com/Downloading_jQuery#Current_Release), and include it before _jquery.i18n.js_ in your HTML source. See the _examples_ folder for examples.

This library is also available as a [bower](http://bower.io/) component under the name *jquery-i18n*.

Usage
-----

Before you can do any translation you have to initialise the plugin with a 'dictionary' (basically a property list mapping keys to their translations).

```javascript
var my_dictionary = {
    'some text':      'a translation',
    'some more text': 'another translation'
}
$.i18n.load(my_dictionary);
```

Once you've initialised it with a dictionary, you can translate strings using the $.i18n._() function, for example:

```javascript
$('div#example').text($.i18n._('some text'));
```

or using $('selector')._t() function

```javascript
$('div#example')._t('some text');
```

Wildcards
---------

It's straightforward to pass dynamic data into your translations. First, add _%s_ in the translation for each variable you want to swap in :

```javascript
var my_dictionary = {
    "wildcard example"  : "We have been passed two values : %s and %s."
}
$.i18n.load(my_dictionary);
```

Next, pass values in sequence after the dictionary key when you perform the translation :

```javascript
$('div#example').text($.i18n._('wildcard example', 100, 200));
```

or

```javascript
$('div#example')._t('wildcard example', 100, 200);
```

This will output _We have been passed two values : 100 and 200._

Because some languages will need to order arguments differently to english, you can also specify the order in which the variables appear :

```javascript
var my_dictionary = {
    "wildcard example"  : "We have been passed two values : %2$s and %1$s."
}
$.i18n.load(my_dictionary);

$('div#example').text($.i18n._('wildcard example', 100, 200));
```

This will output: _We have been passed two values: 200 and 100._

If you need to explicitly output the string _%s_ in your translation, use _%%s_ :

```javascript
var my_dictionary = {
    "wildcard example"  : "I have %s literal %%s character."
}
$.i18n.load(my_dictionary);

$('div#example').text($.i18n._('wildcard example', 1));
```

This will output: _I have 1 literal %%s character._

Building From Scratch
---------------------

Use `npm install` to install the dependencies, and `grunt` to run the build.


Change history
-----------

* **Version 1.1.1 (2014-01-05)** : Use html() instead of text() when rendering translations.
* **Version 1.1.0 (2013-12-31)** : Use grunt, update printf implementation, `setDictionary` is now `load` (thanks to [ktmud](https://github.com/ktmud)).
* **Version 1.0.1 (2013-10-11)** : Add bower support.
* **Version 1.0.0 (2012-10-14)** : 1.0 release - addition of a test suite (huge thanks to [alexaitken](https://github.com/alexaitken)), plus a major cleanup.

Bug Reports
-----------

If you come across any problems, please [create a ticket](https://github.com/recurser/jquery-i18n/issues) and we'll try to get it fixed as soon as possible.


Contributing
------------

Once you've made your commits:

1. [Fork](http://help.github.com/fork-a-repo/) jquery-i18n
2. Create a topic branch - `git checkout -b my_branch`
3. Push to your branch - `git push origin my_branch`
4. Create a [Pull Request](http://help.github.com/pull-requests/) from your branch
5. That's it!


Author
------

Dave Perrett :: hello@daveperrett.com :: [@daveperrett](http://twitter.com/daveperrett)


Copyright
---------

Copyright (c) 2010 Dave Perrett. See [License](https://github.com/recurser/jquery-i18n/blob/master/LICENSE) for details.



