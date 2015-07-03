Next release
============

Features
--------

- The ``authz``, ``identity``, and ``notification`` modules are now
  exposed as public API on the ``annotator`` page global.

- The ``notifier``, ``identityPolicy`` and ``authorizationPolicy`` are now
  retrieved from component registry. It should now be possible to register
  alternative implementations.

- Performance of the highlighter should be slightly improved.

- Showing the viewer with a mouse hover should be much faster when there are
  many overlapping highlights. (#520)

- The ``getGlobal()`` function of the ``util`` module has been removed and
  Annotator should now work with Content Security Policy rules that prevent
  ``eval`` of code.

- The ``markdown`` extension has been upgraded to require and support version
  1.0 or greater of the Showdown library.

Bug Fixes
---------

- Fix a bug in the ``ui.filter`` extension so that the ``filters`` option
  now works as specified.

- Make the highlighter work even when the global ``document`` symbol is not
  ``window.document``.

- Fix an issue with the editor where adding custom fields could result in
  fields appearing more than once. (#533)

- With the ``autoViewHighlights`` options of the ``viewer``, don't show the
  viewer while the primary mouse button is pressed. Before, this prevention
  applied to every button except the primary button, which was not the intended
  behavior.

Documentation
-------------

- Fix some broken links.

- Fix some example syntax.

- Add example markup in the documentation for the ``document`` extension.



2.0.0-alpha.2 (2015-04-24)
==========================

- Started changelog.
