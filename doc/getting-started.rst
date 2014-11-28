Getting started with Annotator
==============================

The Annotator libraries
-----------------------

To get the Annotator up and running on your website you'll need to
either link to a hosted version or deploy the Annotator source files
yourself. Details of both are provided below.

.. note::

    If you are using Wordpress there is also a `Annotator Wordpress
    plugin <http://wordpress.org/extend/plugins/annotator-for-wordpress/>`__
    which will take care of installing and integrating Annotator for you.

Hosted Annotator Library
~~~~~~~~~~~~~~~~~~~~~~~~

For each Annotator release, we make available the following assets:

::

    http://assets.annotateit.org/annotator/{version}/annotator-full.min.js
    http://assets.annotateit.org/annotator/{version}/annotator.min.js
    http://assets.annotateit.org/annotator/{version}/annotator.{pluginname}.min.js
    http://assets.annotateit.org/annotator/{version}/annotator.min.css

Use ``annotator-full.min.js`` if you want to include both the core and
all plugins in a single file. Use ``annotator.min.js`` if you need only
the core. You can add individual plugins by including the relevant
:samp:`annotator.{pluginname}.min.js` files.

For example, a full version of the Annotator can be loaded with the
following code:

.. code:: html

    <script src="http://assets.annotateit.org/annotator/v1.2.5/annotator-full.min.js"></script>
    <link rel="stylesheet" href="http://assets.annotateit.org/annotator/v1.2.5/annotator.min.css">

Deploy the Annotator Locally
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To do this visit the `download
area <http://github.com/okfn/annotator/downloads>`__ and grab the latest
version. This contains the Annotator source code as well as the plugins
developed as part of the Annotator project.

Including Annotator on your webpage
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You need to link the Annotator Javascript and CSS into the page.

.. note:: Annotator requires jQuery 1.6 or greater.

.. code:: html

    <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.7/jquery.min.js"></script>
    <script src="http://assets.annotateit.org/annotator/v1.1.0/annotator-full.min.js"></script>
    <link rel="stylesheet" href="http://assets.annotateit.org/annotator/v1.1.0/annotator.min.css">

Setting up Annotator
--------------------

Setting up Annotator requires only a single line of code. Use jQuery to
select the element that you would like to annotate eg.
``<div id="content">...</div>`` and call the ``.annotator()`` method on
it:

.. code:: javascript

    jQuery(function ($) {
        $('#content').annotator();
    });

Annotator will now be loaded on the ``#content`` element. Select some
text to see it in action.

Options
-------

You can optionally specify options:

``readOnly``
    True to allow viewing annotations, but not creating or editing them.
    Defaults to ``false``.

.. code:: javascript

    jQuery(function ($) {
        $('#content').annotator({
            readOnly: true
        });
    });

Setting up the default plugins
------------------------------

We include a special setup function in the ``annotator-full.min.js``
file that installs all the default plugins for you automatically. To run
it just add a call to ``.annotator("setupPlugins")``.

.. code:: javascript

    jQuery(function ($) {
        $('#content').annotator()
                     .annotator('setupPlugins');
    });

This will set up the following:

1. The :doc:`Tags <plugins/tags>`, :doc:`Filter <plugins/filter>` &
   :doc:`Unsupported <plugins/unsupported>` plugins.
2. The :doc:`Auth <plugins/auth>`, :doc:`Permissions <plugins/permissions>` and
   :doc:`Store <plugins/store>` plugins, for interaction with the `AnnotateIt
   store <http://annotateit.org>`__. NOTE: The Permissions plugin needs to be
   referred to as AnnotateItPermissions when configuring it with setupPlugins.
3. If the `Showdown <https://github.com/coreyti/showdown>`__ library has
   been included on the page the :doc:`plugins/markdown` will also
   be loaded.

You can further customise the plugins by providing an object containing
options for individual plugins. Or to disable a plugin set it's
attribute to ``false``.

.. code:: javascript

    jQuery(function ($) {
        // Customise the default plugin options with the third argument.
        $('#content').annotator()
                     .annotator('setupPlugins', {}, {
                       // Disable the tags plugin
                       Tags: false,
                       // Filter plugin options
                       Filter: {
                         addAnnotationFilter: false, // Turn off default annotation filter
                         filters: [{label: 'Quote', property: 'quote'}] // Add a quote filter
                       }
                     });
    });

Adding more plugins
-------------------

To add a plugin first make sure that you're loading the script into the
page. Then call ``.annotator('addPlugin', 'PluginName')`` to load the
plugin. Options can also be passed to the plugin as additional
parameters after the plugin name.

Here we add the tags plugin to the page:

.. code:: javascript

    jQuery(function ($) {
        $('#content').annotator()
                     .annotator('addPlugin', 'Tags');
    });

For more information on available plugins check the navigation to the right of
this article. Or to create your own check the :doc:`creating a plugin section
<hacking/plugin-development>`.

Saving annotations
------------------

In order to keep your annotations around longer than a single page view
you'll need to set up a store on your server or use an external service
like `AnnotateIt <http://annotateit.org>`__. For more information on
storing annotations check out the :doc:`Store Plugin <plugins/store>` on the wiki.
