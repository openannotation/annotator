``Filter`` plugin
=================

This plugin allows the user to navigate and filter the displayed
annotations.

Interface Overview
------------------

The plugin adds a toolbar to the top of the window. This contains the
available filters that can be applied to the current annotations.

Usage
-----

Adding the Filter plugin to the annotator is very simple. Add the
annotator to the page using the ``.annotator()`` jQuery plugin. Then
call the ``.addPlugin()`` method by calling
``.annotator('addPlugin', 'Filter')``.

.. code:: javascript

      var content = $('#content').annotator().annotator('addPlugin', 'Filter');

Options
~~~~~~~

There are several options available to customise the plugin.

-  ``filters``: This is an array of filter objects. These will be added
   to the toolbar on load.
-  ``addAnnotationFilter``: If ``true`` this will display the default
   filter that searches the annotation text.

Filters
~~~~~~~

Filters are very easy to create. The options require two properties a
``label`` and an annotation ``property`` to search for. For example if
we wanted to filter on an annotations quoted text we can create the
following filter.

.. code:: javascript

      content.annotator('addPlugin', 'Filter', {
        filters: [
          {
            label: 'Quote',
            property: 'quote'
          }
        ]
      });

You can also customise the filter logic that determines if an annotation
should be filtered by providing an ``isFiltered`` function. This
function receives the contents of the filter input as well as the
annotation property. It should return ``true`` if the annotation should
remain highlighted.

Heres an example that uses the ``annotation.tags`` property, which is an
array of tags:

.. code:: javascript

      content.annotator('addPlugin', 'Filter', {
        filters: [
          {
            label: 'Tag',
            property: 'tags',
            isFiltered: function (input, tags) {
              if (input && tags && tags.length) {
                var keywords = input.split(/\s+/g);
                for (var i = 0; i < keywords.length; i += 1) {
                  for (var j = 0; j < tags.length; j += 1) {
                    if (tags[j].indexOf(keywords[i]) !== -1) {
                      return true;
                    }
                  }
                }
              }
              return false;
          }}
        ]
      });
