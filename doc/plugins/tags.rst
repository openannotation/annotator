``Tags`` plugin
===============

This plugin allows the user to tag their annotations with keywords.

Interface Overview
------------------

The following elements are added to the Annotator interface by this
plugin.

Viewer
^^^^^^

The plugin adds a section to a viewed annotation displaying any tags
that have been added.

Editor
^^^^^^

The plugin adds an input field to the editor allowing the user to enter
a space separated list of tags.

Usage
-----

Adding the tags plugin to the annotator is very simple. Simply add the
annotator to the page using the ``.annotator()`` jQuery plugin. Then
call the ``.addPlugin()`` method by calling
``.annotator('addPlugin', 'Tags')``.

.. code:: javascript

      var content = $('#content').annotator().annotator('addPlugin', 'Tags');

Options
~~~~~~~

*There are no options available for this plugin*

Adding autocompletion of tags
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

See `this
example <https://github.com/okfn/annotator/issues/92#issuecomment-3985124>`__
using jQueryUI autocomplete.
