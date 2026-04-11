# Annotator Introduction

Annotator is a browser-side annotation library. Its job is to let a user select text in a web page, create an annotation around that selection, persist that annotation somewhere, and render the annotation back into the page so it can be viewed and edited later.

This repository is not a complete hosted product. It is mainly the client library, plus docs, tests, and a demo page. Persistence is intentionally separated out behind a storage interface.

## What Problem It Solves

The core use case is simple:

1. A user highlights text in a page.
2. Annotator captures the selected quote plus range selectors.
3. The user adds comment text, tags, or permissions metadata.
4. The annotation is stored somewhere persistent.
5. The annotation can later be loaded and rendered back into the page.

That gives you the basis for Google-Docs-style annotation on arbitrary web content.

## Mental Model

The central object is `annotator.App`.

`App` is not the UI itself. It is a composition point that wires together a set of modules:

- authorization policy
- identity policy
- notifier
- storage implementation
- UI modules

On startup, the app constructs a `StorageAdapter` around the configured storage implementation and exposes it as `app.annotations`.

In practice, a typical setup looks like this:

```js
var app = new annotator.App();
app.include(annotator.ui.main);
app.include(annotator.storage.http, {
  prefix: 'http://example.com/api'
});
app.start().then(function () {
  app.annotations.load();
});
```

## How Annotation Creation Works

At a high level, the browser flow is:

1. `annotator.ui.main` listens for text selection events on a target element.
2. The selection is turned into an annotation object containing at least:
   - `quote`
   - `ranges`
3. The adder/editor UI lets the user confirm and edit the annotation.
4. `app.annotations.create(annotation)` is called.
5. `StorageAdapter` runs hooks such as `beforeAnnotationCreated`.
6. The configured storage backend creates the annotation.
7. `annotationCreated` hooks run and the highlighter draws the annotation in the page.

The same pattern applies to update, delete, and load.

## Storage Model

Storage is deliberately pluggable.

Built-in options in this repo include:

- `annotator.storage.noop`
  - assigns IDs and does not persist anything
- `annotator.storage.debug`
  - logs storage events to the console
- `annotator.storage.http`
  - talks to a remote HTTP+JSON annotation API

The documented default HTTP model expects a separate backend service. The docs point to `annotator-store` as the historical reference backend:

- `https://github.com/openannotation/annotator-store`

So the intended architecture is:

- this repo: browser client library
- separate backend: annotation persistence and querying

## Identity And Permissions

Identity and authorization are also pluggable.

By default:

- `annotator.identity.simple` treats the current user as an opaque identifier
- `annotator.authz.acl` uses annotation fields such as `permissions` or `user` to decide whether actions are allowed

That means Annotator is designed to be embedded into other systems rather than forcing one account model.

## What Is In This Repo

- `src/`
  - core library code
- `test/`
  - unit/browser tests
- `docs/`
  - project documentation in plain Markdown
- `demo.html`
  - local demo page for the browser bundle
- `tools/`
  - build helpers
- `REBOOT.md`
  - reboot framing note
- `ASSESSMENT.md`
  - current hands-on technical assessment
- `REVIVAL-PLAN.md`
  - proposed path to get the project working again

## Current Status Snapshot

The design still makes sense, but the toolchain is from a much older JavaScript era:

- Node `0.10/0.11` era assumptions
- Browserify
- jQuery `1.11`
- Karma + Mocha
- PhantomJS-era test configuration
- old CSS tooling

The good news is that the project is not totally stranded:

- dependencies can still be installed
- the browser bundle now builds on a modern Node version
- the test suite can run successfully in modern headless Chrome
- the dev page serves and loads in a real browser process

So the project has moved past “can this even run?” and into the more useful phase: modernizing the toolchain and clarifying the supported path forward.
