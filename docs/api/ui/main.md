# annotator.ui package

<div class="function">

annotator.ui.main(\[options\])

A module that provides a default user interface for Annotator that
allows users to create annotations by selecting text within (a part of)
the document.

Example:

    app.include(annotator.ui.main);

param Object options  

> <div class="attribute">
>
> options.element
>
> A DOM element to which event listeners are bound. Defaults to
> `document.body`, allowing annotation of the whole document.
>
> </div>
>
> <div class="attribute">
>
> options.editorExtensions
>
> An array of editor extensions. See the `~annotator.ui.editor.Editor`
> documentation for details of editor extensions.
>
> </div>
>
> <div class="attribute">
>
> options.viewerExtensions
>
> An array of viewer extensions. See the `~annotator.ui.viewer.Viewer`
> documentation for details of viewer extensions.
>
> </div>

</div>
