Internationalisation and localisation (I18N, L10N)
==================================================

Annotator has rudimentary support for localisation of its interface.

For users
---------

If you wish to use a provided translation, you need to add a ``link``
tag pointing to the ``.po`` file, as well as include ``gettext.js``
before you load the Annotator. For example, for a French translation:

::

    <link rel="gettext" type="application/x-po" href="locale/fr/annotator.po">
    <script src="lib/vendor/gettext.js"></script>

This should be all you need to do to get the Annotator interface
displayed in French.

For translators
---------------

We now use `Transifex <http://transifex.net/>`__ to manage localisation
efforts on Annotator. If you wish to contribute a translation you'll
first need to sign up for a free account at

https://www.transifex.net/plans/signup/free/

Once you're signed up, you can go to

https://www.transifex.net/projects/p/annotator/

and get translating!

For developers
--------------

Any localisable string in the core of Annotator should be wrapped with a
call to the gettext function, ``_t``, e.g.

::

    console.log(_t("Hello, world!"))

Any localisable string in an Annotator plugin should be wrapped with a
call to the gettext function, ``Annotator._t``, e.g.

::

    console.log(Annotator._t("Hello from a plugin!"))

To update the localisation template (``locale/annotator.pot``), you
should run the ``i18n:update`` Cake task:

::

    cake i18n:update

You should leave it up to individual translators to update their
individual ``.po`` files with the ``locale/l10n-update`` tool.
