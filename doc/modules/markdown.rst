``Markdown`` Plugin
===================

The Markdown plugin allows you to use
`Markdown <http://daringfireball.net/projects/markdown/>`__ in your
annotation comments. It will then render them in the Viewer.

Requirements
------------

This plugin requires that the
`Showdown <http://github.com/coreyti/showdown>`__ Markdown library be
loaded in the page before the plugin is added to the annotator. To do
this simply
`download <http://github.com/coreyti/showdown/raw/master/compressed/showdown.js>`__
the showdown.js and include it on your page before the annotator.

.. code:: html

   <script src="javascript/jquery.js"></script>
   <script src="javascript/showdown.js"></script>
   <script src="javascript/annotator.min.js"></script>
   <script src="javascript/annotator.markdown.min.js"></script>

Usage
-----

Adding the Markdown plugin to the annotator is very simple. Simply add
the annotator to the page using the ``.annotator()`` jQuery plugin and
retrieve the annotator object using ``.data('annotator')``. Then add the
``Markdown`` plugin.

.. code:: javascript

   var content = $('#content').annotator();
   content.annotator('addPlugin', 'Markdown');

Options
~~~~~~~

*There are no options available for this plugin*
