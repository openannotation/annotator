Annotator architecture
======================

There are questions about the overall architecture of Annotator 2.0 that remain
unanswered. This document intends to lay out some of the higher-level
architectural issues and make some proposals for review by others.

First, a reminder of why we're restructuring Annotator at all. There are two
overarching reasons to do this work:

1.  To better serve the needs of more advanced users of the Annotator
    codebase [#adv]_. In particular, in Annotator 1.2.x parts of the UI are
    hard-coded into the core of Annotator and are not easily removed or swapped.

    We want Annotator 2.0 to serve users who don't want or need all of
    Annotator's features. In particular, it should be possible to use the
    underlying utilities for building annotation applications, without requiring
    that you use Annotator's UI.

2.  To put Annotator in a better position for the future, so that we can begin
    to extend the features provided by the library in a sustainable way. Adding
    features such as image, video, or PDF annotation to Annotator 1.2.x is very
    hard to achieve in a way that is both simple and reusable.

    Our goal with Annotator 2.0 is to reflect on the lessons learned from the
    naive plugin system of Annotator 1.2, and build a much more powerful
    annotation library without adding unnecessary complexit.

Current work
------------

Work to solve these issues can already be found on the master branch of the
Annotator repository. Item 1) has been substantially addressed, by splitting out
the current Annotator UI into reusable library components.

We (the maintainers) have been talking about some of the problems posed by item
2), and how the current restructuring may fall short of adequately setting us up
for the future.

Here's the current state of play on the master branch:

::

    +-----------------------------------------------------------+
    |                                                           |
    |                         Annotator                         |
    |                                                           |
    +-----------------------------------------------------------+

    +-------------------------------+  +-----------+  + - - - - -
    |                               |  |           |     Other
    |        Annotator.Core         |  | DefaultUI |  |  Lifecycle
    |                               |  |           |     Plugins...
    +-------------------------------+  +-----------+  + - - - - -

    +---------+  +-------+  +-------+
    |         |  |       |  |       |
    | Storage |  | Authz |  | Ident |
    |         |  |       |  |       |
    +---------+  +-------+  +-------+

Annotator is a composition of a default UI, a storage component, and a number of
other swappable components.

The key concept of the above structure (not intended to be apparent from the
diagram) is that the entire lifecycle of an annotation is mediated through the
storage.

When annotations are to be created/updated, a user or a piece of UI code tells
the storage plugin to create/update an annotation [#storage]_. When this happens
the familiar "lifecycle hooks" are run::

    beforeAnnotationCreated
    annotationCreated
    beforeAnnotationUpdated
    annotationUpdated

There remains a class of generic plugins known as "lifecycle plugins," which can
respond to these hooks (previously implemented as events). The order in which
lifecycle hooks is called is undefined, but the hook callbacks can defer or
cancel the annotation lifecycle event (by returning a Promise object).

There are a number of issues with this design:

1. Persistence (through the storage component) is on the critical path for CRUD
   of annotations. This isn't necessarily a problem, but it's probably
   unnecessary. Moreover, the question of how to deal adequately with errors
   from a backend accessed over an unreliable network has not been addressed and
   would be complicated by the current hook system.

2. Responsibilities for (and scheduling of) serialization and deserialization of
   annotations are not clear. Annotations are bare JavaScript objects passed
   around. Unserializable properties (such as references to DOM Nodes) are kept
   in a magic ``_local`` field on the annotation.

3. The naming and sequencing of lifecycle events is messy. We are currently
   conflating two processes: the persistence of user actions ("create a new
   annotation", "delete this annotation"), and the attachment and updating of
   annotations in the DOM ("I loaded this annotation, draw it", "This annotation
   has been deleted, remove it").

A better option?
----------------

So, after some discussion with my co-maintainers, I'd like to make a proposal
for a better option that resolves some of these issues, while also helping us to
understand what better first-class tools (i.e. DOM APIs) for annotating might
look like in the future.

::

    + - - - - - - - - - - +   +-----------------------------------------------+
                              |                                               |
    |     Other clients   |   |                   Annotator                   |
                              |                                               |
    + - - + - - - - ^ - - +   +-----------------------------------------------+
          |         |
          |         |         +---------+  +-----------+    +------+  +-------+
          |         |         |         |  |           |    |      |  |       |
          |         |         | Storage |  |    UI     |    | Auth |  | Ident |
          |         |         |         |  |           |    |      |  |       |
          |         |         +---------+  +-----------+    +------+  +-------+
          |         |
    +-----v---------+----------------------------------+
    |                                                  |
    |        DOMAnnotations (window.Annotations)       |
    |                                                  |
    +--------------------------------------------------+

The most important ideas are as follows:

1. Persisted state and DOM state are not the same thing, and should be treated
   separately. A new ``DOMAnnotations`` API (of which more later) serves as the
   model of DOM state. It speaks in terms of first-class ``Annotation`` objects,
   and is responsible for managing and querying the state of annotations on the
   current document.

2. Persistence is just another client of the ``DOMAnnotations`` model. Rather
   than waiting on an HTTP round-trip before drawing an Annotation, we focus
   instead on regularly updating the state of the backend to reflect the current
   state of annotation on the document [#persistence]_.

3. Annotator is but one client of the underlying annotation data model, and
   shouldn't have privileged access to it.

So, what are the responsibilities of the ``DOMAnnotations`` layer and how do
they differ from those of ``Annotator``? The key distinction is that
``DOMAnnotation`` is an API to manipulate and query the **current state** of
annotations on the **current document**. It knows nothing about persistence, and
can only be used to create, update, and remove annotations from the currently
loaded DOM. Annotator is a client of these APIs and provides its own tools for
creating, editing, displaying, and eventually persisting annotations.

A proposed set of APIs for ``DOMAnnotations`` is included below, but it may help
to provide a few examples of how particular use cases would work.

Creating a annotation on text content
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

1. User makes a selection of some text in the document.
2. Annotator shows a widget that allows a user to communicate intent to
   annotate.
3. The user activates this and is presented with an editor to allow them to add
   their notes. They submit the editor.
4. Annotator creates an annotation attached to the underlying ranges selected by
   the user using the ``DOMAnnotations`` APIs::

       var body = getAnnotationBody();   # The body of the annotation
       var ranges = getSelectedRanges(); # The ranges selected by the user

       var target = window.Annotations.TextTarget(ranges);
       var annotation = document.createAnnotation();
       annotation.addBody(body);
       annotation.addTarget(target);

5. This sequence of steps fires a custom DOM Event, ``annotationcreate``, on the
   selected text nodes, as soon as the first target is added.
6. The Annotator storage component is listening for this ``annotationcreate``
   event on some parent node of the selected textnodes. At its own discretion it
   sends requests to the backend storage, which will likely included a
   serialized copy of the annotation, which can be obtained using a simple::

       JSON.stringify(annotation);

   This is possible because annotations are first-class objects that can provide
   a ``.toJSON()`` method. Annotation bodies and targets can also be first-class
   objects that can do likewise.

Updating an annotation
~~~~~~~~~~~~~~~~~~~~~~

1. User indicates that they want to make a change to an annotation.
2. Annotator shows an editor and the user makes their intended edits.
3. Annotator updates the annotation [#changes]_::

       annotation.removeBody(annotation.bodies[0])
       annotation.addBody(newBody)

4. This sequence of steps fires a custom DOM Event, ``annotationchange``, on the
   nodes associated with the annotation target(s).
5. The Annotator storage component is listening for this ``annotationchange``
   event on some parent node of the selected textnodes. At its own discretion it
   sends requests to the backend storage.

Loading an annotation from a remote store
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

1. The Annotator storage component retrieves a serialized version of an
   annotation from its backend.
2. Annotator uses whatever internal mechanism it needs to in order to find the
   part of the document to which this serialized annotation is intended to be
   attached. This may include fuzzy matching, awareness of annotations which
   refer to unrendered parts of the DOM, etc.
3. If Annotator can reattach the annotation, it does so in the usual way::

       var annotation;
       var bodies = getBodies(serializedAnnotation);
       var targets = getTargets(serializedAnnotation);

       if (targets.length > 0) {
           annotation = document.createAnnotation();
           for (<body in bodies>) {
               annotation.addBody(body);
           }
           for (<target in targets) {
               // target at this point is an object that contains references to
               // nodes within the DOM
               annotation.addTarget(target);
           }
       }

4. Relevant pieces of the Annotator UI (highlights, etc.) are listening to
   ``annotationcreate`` events and render themselves appropriately.

Proposed ``DOMAnnotations`` APIs
--------------------------------

We introduce the Annotations global object, to serve as a canonical
location for annotation related types. In the short term, this can also
be used as a site for calling a polyfill, i.e.

::

    Annotations.polyfill()

Creating an annotation
~~~~~~~~~~~~~~~~~~~~~~

::

    var annotation = <Annotations | document>.createAnnotation();  # => Annotation

Rationale: by analogy with ``document.createElement(tagname)``, or
``document.createRange()``. Returns an object of type ``Annotation``.

Adding and removing targets
~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

    annotation.addTarget(new Annotations.TextTarget(range));  # => void

and/or

::

    annotation.addTarget(new Annotations.ImageTarget(el, {x: 0, y: 0, w: 100, h: 50}));  # => void

targets are (by analogy with Range objects) live objects, in the sense
that mutating one previously added to an annotation is a valid operation.

We also provide:

::

    annotation.removeTarget(target);  # => void

Also, since addTarget is a void function, and by analogy with
``selection.removeAllRanges()``, it might be nice to provide:

::

    annotation.removeAllTargets();  # => void

Accessing annotation targets
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

    annotation.targets

Rationale: few if any DOM natives have getter methods. We will need to
ensure that this property is appropriately isolated from internal state
or is immutable.

Removing an annotation
~~~~~~~~~~~~~~~~~~~~~~

::

    <Annotations | document>.removeAnnotation(annotation);

Rationale: this could conceivably be an instance method of
``Annotation`` called ``remove()``, but consider the following scenario.
I want to make an annotation that has targets in two different documents
(for example, to compare usage of a key word in two different texts). In
some circumstances it is possible to have access to more than one
document within a single execution context (e.g. iframes satisfying
`SOP <https://en.wikipedia.org/wiki/Same-origin_policy>`__), and I might
want to do something like:

::

    var annotation = document.createAnnotation();
    var documentB = document.querySelector('iframe').contentDocument;

    var rangeA = document.createRange();
    rangeA.selectNode(document.querySelector('h1'));

    var rangeB = documentB.createRange();
    rangeB.selectNode(documentB.querySelector('h1'));

    annotation.addTarget(Annotations.TextTarget([rangeA]));
    annotation.addTarget(Annotations.TextTarget([rangeB]));

This now raises the question of should I be able to find this annotation
by calling

::

    documentB.getAnnotations(documentB.querySelector('h1'));

My inclination is that we should, which presupposes that
``Annotation``\ s can be added and removed to different documents
independently, leading to the proposed API of
``document.removeAnnotation(<annotation>)``.

Querying annotations
~~~~~~~~~~~~~~~~~~~~

::

    <Annotations | document>.getAnnotations(<Node | NodeList>);  # => Array[Annotation]


Events
~~~~~~

Adding the first target to a new ``Annotation`` triggers an ``annotationcreate``
event on nodes associated with that target. The annotation is available at
``event.detail.annotation``.

Modifying an annotation (or any of its subproperties: targets, bodies,
other data, etc.) triggers an ``annotationchange`` event on every node
associated with that annotation's targets. In the event that a target is
removed, the event is also triggered on the nodes of the removed target. The
annotation is available at ``event.detail.annotation``.

Removing an annotation triggers an ``annotationremove`` event on every node
associated with that annotation's targets. The annotation is available at
``event.detail.annotation``.

----

.. rubric:: Footnotes

.. [#adv] We intend to do this while maintaining a similar ease-of-use for
          simpler needs.

.. [#storage] In fact, these calls are mediated through a wrapper called the
              ``StorageAdapter``, but this detail does not affect the current
              discussion.

.. [#persistence] This idea obviously nods towards many others who have done
                  serious thinking in this area: `Offline First
                  <http://offlinefirst.org/>`_, `SLEEP
                  <http://dataprotocols.org/sleep/>`_, `CouchDB
                  <http://dataprotocols.org/couchdb-replication/>`_.

.. [#changes] Open question: is there a nicer way to allow annotations to know
              that bodies have changed without requiring removal and addition of
              bodies like this.
