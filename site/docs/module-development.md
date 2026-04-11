# Module development

## The basics

An Annotator `module` is a function that can be passed to
`~annotator.App.prototype.include` in order to extend the functionality
of an Annotator application.

The simplest possible Annotator module looks like this:

    function myModule() {
        return {};
    }

This clearly won't do very much, but we can include it in an
application:

    app.include(myModule);

If we want to do something more interesting, we have to provide some
module functionality. There are two ways of doing this:

1.  module hooks
2.  component registration

Use module hooks unless you are replacing core functionality of
Annotator. Module hooks are functions that will be run by the
`~annotator.App` when important things happen. For example, here's a
module that will say `Hello, world!` to the user when the application
starts:

    function helloWorld() {
        return {
            start: function (app) {
                app.notify("Hello, world!");
            }
        };
    }

Just as before, we can include it in an application using
`~annotator.App.prototype.include`:

    app.include(helloWorld);

Now, when you run `app.start();`, this module will send a notification
with the words `Hello, world!`.

Or, here's another example that uses the [HTML5 Audio
API](https://developer.mozilla.org/en-US/docs/Web/API/Web_Audio_API) to
play a sound every time a new annotation is made[^1]:

    function fanfare(options) {
        options = options || {};
        options.url = options.url || 'trumpets.mp3';

        return {
            annotationCreated: function (annotation) {
                var audio = new Audio(options.url);
                audio.play();
            }
        };
    }

Here we've added an `options` argument to the module function so we can
configure the module when it's included in our application:

    app.include(fanfare, {
        url: "brass_band.wav"
    });

You may have noticed that the `annotationCreated` module hook function
here receives one argument, `annotation`. Similarly, the `start` module
hook function in the previous example receives an `app` argument. A
complete reference of arguments and hooks is covered in the
`module-hooks` section.

## Loading custom modules

When you write a custom module, you'll end up with a JavaScript function
that you need to reference when you build your application. In the
examples above we've just defined a function and then used it straight
away. This is probably fine for small examples, but when things get a
bit more complicated you might want to put your modules in a namespace.

For example, if you were working on an application for annotating
Shakespeare's plays, you might put all your modules in a namespace
called `shakespeare`:

    var shakespeare = {};
    shakespeare.fanfare = function fanfare(options) {
        ...
    };
    shakespeare.addSceneData = function addSceneData(options) {
        ...
    };

You get the idea. You can now `~annotator.App.prototype.include` these
modules directly from the namespace:

    app.include(shakespeare.fanfare, {
        url: "elizabethan_sackbuts.mp3"
    });
    app.include(shakespeare.addSceneData);

## Module hooks

Hooks are called by the application in order to delegate work to
registered modules. This is a list of module hooks, when they are
called, and what arguments they receive.

It is possible to add your own hooks to your application by invoking the
`~annotator.App.prototype.runHook` method on the application instance.
The return value is a `Promise` that resolves to an `Array` of the
results of the functions registered for that hook (the order of which is
undefined).

Hook functions may return a value or a `Promise`. The latter is
sometimes useful for delaying actions. For example, you may wish to
return a `Promise` from the `beforeAnnotationCreated` hook when an
asynchronous task must complete before the annotation data can be saved.

<div class="function">

configure(registry)

Called when the plugin is included. If you are going to register
components with the registry, you should do so in the
<span class="title-ref">configure</span> module hook.

param Registry registry  
The application registry.

</div>

<div class="function">

start(app)

Called when `~annotator.App.prototype.start` is called.

param App app  
The configured application.

</div>

<div class="function">

destroy()

Called when `~annotator.App.prototype.destroy` is called. If your module
needs to do any cleanup, such as unbinding events or disposing of
elements injected into the DOM, it should do so in the
<span class="title-ref">destroy</span> hook.

</div>

<div class="function">

annotationsLoaded(annotations)

Called with annotations retrieved from storage using
`~annotator.storage.StorageAdapter.load`.

param Array\[Object\] annotations  
The annotation objects loaded.

</div>

<div class="function">

beforeAnnotationCreated(annotation)

Called immediately before an annotation is created. Modules may use this
hook to modify the annotation before it is saved.

param Object annotation  
The annotation object.

</div>

<div class="function">

annotationCreated(annotation)

Called when a new annotation is created.

param Object annotation  
The annotation object.

</div>

<div class="function">

beforeAnnotationUpdated(annotation)

Called immediately before an annotation is updated. Modules may use this
hook to modify the annotation before it is saved.

param Object annotation  
The annotation object.

</div>

<div class="function">

annotationUpdated(annotation)

Called when an annotation is updated.

param Object annotation  
The annotation object.

</div>

<div class="function">

beforeAnnotationDeleted(annotation)

Called immediately before an annotation is deleted. Use if you need to
conditionally cancel deletion, for example.

param Object annotation  
The annotation object.

</div>

<div class="function">

annotationDeleted(annotation)

Called when an annotation is deleted.

param Object annotation  
The annotation object.

</div>

**Footnotes**

[^1]: Yes, this might be quite annoying. Probably not an example to copy
    wholesale into your real application...
