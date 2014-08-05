``Unsupported`` plugin
======================

The Annotator only supports browsers that have the
``window.getSelection()`` method (for a table of support please see
`this Quirksmode
article <http://www.quirksmode.org/dom/range_intro.html#link2>`__). This
plugin provides a notification to users of these unsupported browsers
letting them know that the plugin has not loaded.

Usage
-----

Adding the unsupported plugin to the annotator is very simple. Simply
add the annotator to the page using the ``.annotator()`` jQuery plugin.
Then call the ``.addPlugin()`` method eg.
``.annotator('addPlugin', 'Unsupported')``.

.. code:: javascript

      var content = $('#content').annotator();
      content.annotator('addPlugin', 'Unsupported');

Options
~~~~~~~

You can provide options

-  ``message``: A customised message that you wish to display to users.

message
^^^^^^^

The message that you wish to display to users.

.. code:: javascript

      var annotator = $('#content').annotator().data('annotator');

      annotator.addPlugin('Unsupported', {
        message: "We're sorry the Annotator is not supported by this browser"
      });
