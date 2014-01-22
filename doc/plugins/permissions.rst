``Permissions`` plugin
======================

This plugin handles setting the user and permissions properties on
annotations as well as providing some enhancements to the interface.

Interface Overview
------------------

The following elements are added to the Annotator interface by this
plugin.

Viewer
^^^^^^

The plugin adds a section to a viewed annotation displaying the name of
the user who created it. It also checks the annotation's permissions to
see if the current user can **edit**/**delete** the current annotation
and displays controls appropriately.

Editor
^^^^^^

The plugin adds two fields with checkboxes to the annotation editor
(these are only displayed if the current user has **admin** permissions
on the annotation). One to allow anyone to view the annotation and one
to allow anyone to edit the annotation.

Usage
-----

Adding the permissions plugin to the annotator is very simple. Simply
add the annotator to the page using the ``.annotator()`` jQuery plugin
and retrieve the annotator object using ``.data('annotator')``. We now
add the plugin and pass an options object to set the current user.

.. code:: javascript

    var annotator = $('#content').annotator().data('annotator');
    annotator.addPlugin('Permissions', {
      user: 'Alice'
    });

By default all annotations are publicly viewable/editable/deleteable. We
can set our own permissions using the options object.

.. code:: javascript

    var annotator = $('#content').annotator().data('annotator');
    annotator.addPlugin('Permissions', {
      user: 'Alice',
      permissions: {
        'read':   [],
        'update': ['Alice'],
        'delete': ['Alice'],
        'admin':  ['Alice']
      }
    });

Now only our current user can edit the annotations but anyone can view
them.

Options
~~~~~~~

The options object allows you to completely define the way permissions
are handled for your site.

-  ``user``: The current user (required).
-  ``permissions``: An object defining annotation permissions.
-  ``userId``: A callback that returns the user id.
-  ``userString``: A callback that returns the users name.
-  ``userAuthorize``: A callback that allows custom authorisation.
-  ``showViewPermissionsCheckbox``: If ``false`` hides the "Anyone can
   view…" checkbox.
-  ``showEditPermissionsCheckbox``: If ``false`` hides the "Anyone can
   edit…" checkbox.

user (required)
^^^^^^^^^^^^^^^

This value sets the current user and will be attached to all newly
created annotations. It can be as simple as a username string or if your
users objects are more complex an object literal.

.. code:: javascript

    // Simple example.
    annotator.addPlugin('Permissions', {
      user: 'Alice'
    });

    // Complex example.
    annotator.addPlugin('Permissions', {
      user: {
        id: 6,
        username: 'Alice',
        location: 'Brighton, UK'
      }
    });

If you do decide to use an object for your user as well as permissions
you'll need to also provide ``userId`` and ``userString`` callbacks. See
below for more information.

permissions
^^^^^^^^^^^

Permissions set who is allowed to do what to your annotations. There are
four actions:

-  ``read``: Who can view the annotation
-  ``update``: Who can edit the annotation
-  ``delete``: Who can delete the annotation
-  ``admin``: Who can change these permissions on the annotation

Each action should be an array of tokens. An empty array means that
anyone can perform that action. Generally the token will just be the
users id. If you need something more complex (like groups) you can use
your own syntax and provide a ``userAuthorize`` callback with your
options.

Here's a simple example of setting the permissions so that only the
current user can perform all actions:

.. code:: javascript

    annotator.addPlugin('Permissions', {
      user: 'Alice',
      permissions: {
        'read':   ['Alice'],
        'update': ['Alice'],
        'delete': ['Alice'],
        'admin':  ['Alice']
      }
    });

Or here is an example using numerical user ids:

.. code:: javascript

    annotator.addPlugin('Permissions', {
      user: {id: 6, name:'Alice'},
      permissions: {
        'read':   [6],
        'update': [6],
        'delete': [6],
        'admin':  [6]
      }
    });

userId(user)
^^^^^^^^^^^^

This is a callback that accepts a ``user`` parameter and returns the
identifier. By default this assumes you will be using strings for your
ids and simply returns the parameter. However if you are using a user
object you'll need to implement this:

.. code:: javascript

    annotator.addPlugin('Permissions', {
      user: {id: 6, name:'Alice'},
      userId: function (user) {
        if (user && user.id) {
          return user.id;
        }
        return user;
      }
    });
    // When called.
    userId({id: 6, name:'Alice'}) // => Returns 6

NOTE: This function should handle ``null`` being passed as a parameter.
This is done when checking a globally editable annotation.

userString(user)
^^^^^^^^^^^^^^^^

This is a callback that accepts a ``user`` parameter and returns the
human readable name for display. By default this assumes you will be
using a string to represent your users name and id so simply returns the
parameter. However if you are using a user object you'll need to
implement this:

.. code:: javascript

    annotator.addPlugin('Permissions', {
      user: {id: 6, name:'Alice'},
      userString: function (user) {
        if (user && user.name) {
          return user.name;
        }
        return user;
      }
    });
    // When called.
    userString({id: 6, name:'Alice'}) // => Returns 'Alice'

userAuthorize(action, annotation, user)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This is another callback that allows you to implement your own
authorization logic. It receives three arguments:

-  ``action``: Action that is being checked, 'update', 'delete' or
   'admin'. 'create' does not call this callback
-  ``annotation``: The entire annotation object; note that the
   permissions subobject is at ``annotation.permissions``
-  ``user``: current user, as passed in to the permissions plugin

Your function will check to see if the user can perform an action based
on these values.

The default implementation assumes that the user is a simple string and
the tokens used (within ``annotation.permissions``) are also strings so
simply checks that the user is one of the tokens for the current action.

.. code:: javascript

    // This is the default implementation as an example.
    annotator.addPlugin('Permissions', {
      user: 'Alice',
        userAuthorize: function(action, annotation, user) {
          var token, tokens, _i, _len;
          if (annotation.permissions) {
            tokens = annotation.permissions[action] || [];
            if (tokens.length === 0) {
              return true;
            }
            for (_i = 0, _len = tokens.length; _i < _len; _i++) {
              token = tokens[_i];
              if (this.userId(user) === token) {
                return true;
              }
            }
            return false;
          } else if (annotation.user) {
            if (user) {
              return this.userId(user) === this.userId(annotation.user);
            } else {
              return false;
            }
          }
          return true;
        },
    });
    // When called.
    userAuthorize('update', aliceAnnotation, 'Alice') // => Returns true
    userAuthorize('Alice', bobAnnotation, 'Bob')   // => Returns false

.. raw:: html

   <!-- There is code for this in the history.  However, it used the old, simpler API signature, which no longer applies.  Thus, updating it is required. -->

A more complex example might involve you wanting to have a groups
property on your user object. If the user is a member of the 'Admin'
group they can perform any action on the annotation.

// When called by a normal user. userAuthorize('update',
adminAnnotation, { id: 1, group: 'user' }) // => Returns false

// When called by an admin. userAuthorize('update', adminAnnotation, {
id: 2, group: 'Admin' }) // => Returns true

// When called by the owner. userAuthorize('update', regularAnnotation,
ownerOfRegularAnnotation) // => Returns true \`\`\`
