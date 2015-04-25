.. _glossary:

Glossary
========

.. glossary::
   :sorted:

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
