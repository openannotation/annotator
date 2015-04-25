Annotator Roadmap
=================

This document lays out the planned schedule and roadmap for the future
development of Annotator.

For each release below, the planned features reflect what the core team intend
to work on, but are not an exhaustive list of what could be in the release. From
the release of Annotator 2.0 onwards, we will operate a time-based release
process, and any features merged by the relevant cutoff dates will be in the
release.

.. note:: This is a living document. Nothing herein constitutes a guarantee that
          a given Annotator release will contain a given feature, or that a
          release will happen on a specified date.

2.0
+++

What will be in 2.0
-------------------

-  Improved internal API
-  UI component library (the UI was previously "baked in" to Annotator)
-  Support (for most features) for Internet Explorer 8 and up
-  Internal data model consistent with `Open Annotation`_
-  A (beta-quality) storage component that speaks OA JSON-LD
-  Core code translated from CoffeeScript to JavaScript

.. _Open Annotation: http://www.openannotation.org/

Schedule
--------

The following dates are subject to change as needed.

=================  ============================================
November 15, 2014  Annotator 2.0 alpha; major feature freeze
December 1, 2014   Annotator 2.0 beta; complete feature freeze
January  15, 2015  Annotator 2.0 RC1; translation string freeze
2 weeks after RC1  Annotator 2.0 final (or RC2 if needed)
=================  ============================================

The long period between a beta release and RC1 takes account of a) Christmas and
the holiday season and b) time for other developers to test and report bugs.


2.1
+++

The main goals for this release, which we aim to ship by May 1, 2015 (with a
major feature freeze on Mar 15):

-  Support for selections made using the keyboard
-  Support in the core for annotation on touch devices
-  Support for multiple typed selectors in annotations
-  Support for components that resolve ('reanchor') an annotation's selectors
   into a form suitable for display in the page


2.2
+++

The main goals for this release, which we aim to ship by Aug 1, 2015 (with a
major feature freeze on Jun 15):

-  Support for annotation of additional media types (images, possibly video) in
   the core

2.3
+++

The main goals for this release, which we aim to ship by Nov 1, 2015 (with a
major feature freeze on Sep 15):

-  Improved highlight rendering (faster, doesn't modify underlying DOM)
-  Replace existing XPath-based selector code with Rangy_

.. _Rangy: https://github.com/timdown/rangy
