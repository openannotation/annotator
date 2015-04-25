.. _glossary:

Glossary
========

.. glossary::
   :sorted:

   application
      An application is an instance of :class:`annotator.App`. It is the primary
      object that coordinates annotation activities. It can be extended by
      passing a :term:`module` reference to its
      :func:`~annotator.App.prototype.include` method. Typically, you will
      create at least one application when using Annotator. See the API
      documentation for :class:`annotator.App` for details on construction and
      methods.

   hook
      A function that handles work delegated to a :term:`module` by the
      :term:`application`. A hook function can return a value or a
      :term:`Promise`. The arguments to hook functions can vary. See
      :ref:`module-hooks` for a description of the core hooks provided by
      Annotator.

   module
      A module extends the functionality of an :term:`application`, primarily
      through :term:`hook` functions. See the section :doc:`module-development`
      for details about writing modules.

   Promise
      An object used for deferred and asynchronous computations.
      See https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise
      for more information.
