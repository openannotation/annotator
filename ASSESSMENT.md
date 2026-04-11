# Annotator Technical Assessment

This is a hands-on assessment of the current Annotator codebase as checked on `2026-04-11`.

## Scope

The goal of this assessment was to answer a few practical questions:

- what the codebase actually contains
- how the main pieces fit together
- whether the project still installs on a modern machine
- whether lint, build, and test flows still work
- what the first real blockers are

This is still an early assessment. It is not yet a full compatibility audit or browser QA pass.

## Environment Used

- macOS workspace
- Node `v25.8.1`
- npm `11.11.0`

The project itself declares:

- Node `>=0.10 <0.12`

That mismatch matters when interpreting failures.

## What I Checked

### Repository shape

The repo contains:

- a browser library in `src/`
- tests in `test/`
- documentation in `docs/`
- a demo page in `demo.html`
- build helpers in `tools/`

The code identifies itself as `2.0.0-alpha.3`.

### Architecture

The architecture is coherent and modular:

- `annotator.App` is the composition root
- `ui.main` handles text selection, editing, viewing, and highlighting
- `StorageAdapter` handles create/update/delete/load flow and hook dispatch
- storage is pluggable
- identity and authorization are pluggable

This is a real library architecture, not just a one-off demo.

### Storage and backend model

The browser client is designed to persist annotations through a storage implementation.

The documented production path is `annotator.storage.http`, which expects a separate JSON/HTTP backend. The docs reference the historical `annotator-store` server:

- `https://github.com/openannotation/annotator-store`

So this repo is primarily the client-side part of the system, not the whole system.

## Commands Run

### 1. Install dependencies

Initial command:

```bash
npm install
```

Initial result:

- failed because the machine's global npm cache under `/Users/rgrp/.npm` contains root-owned files

Workaround used:

```bash
npm install --cache .npm-cache
```

Result:

- install completed successfully
- npm emitted many deprecation warnings
- npm reported `80 vulnerabilities`

Interpretation:

- the dependency graph is still fetchable
- the project is not blocked at the package-resolution level
- the dependency set is very old and carries substantial security/maintenance debt

### 2. Lint

Command:

```bash
npm run lint
```

Result:

- completed successfully on modern Node
- only emitted runtime warnings from old transitive packages

Interpretation:

- the source tree itself is not immediately broken at the syntax/style level
- this is a good sign for incremental modernization

### 3. Build

Command:

```bash
make pkg/annotator.min.js
```

Initial result:

- failed while generating `pkg/annotator.js`

Observed root cause:

- `tools/cssify.js` instantiates `clean-css`
- the installed `clean-css@3` code calls `util.isRegExp`
- `util.isRegExp` no longer exists in Node `25`

Representative failure:

```text
TypeError: util.isRegExp is not a function
```

Fix applied:

- changed `tools/cssify.js` so CSS minification is optional
- retained CSS enhancement
- avoided letting old `clean-css` crash the build

Current result:

- `make pkg/annotator.min.js` now completes successfully

Interpretation:

- the first concrete build blocker was a localized modern-Node incompatibility in the CSS transform path
- it was fixable without redesigning the library

### 4. Test suite

Command:

```bash
npm test
```

Initial behavior:

- Karma starts
- Browserify preprocessing begins
- the process fails during bundling

Direct reproduction:

```bash
./node_modules/.bin/browserify -d test/init.js > /tmp/annotator-browserify.js
```

Initial result:

- reproduced the same `clean-css` / `util.isRegExp` failure

Second blocker after fixing bundling:

- the default PhantomJS runner could not start on this machine
- the vendored PhantomJS binary is Mach-O `i386`
- this machine is `arm64`

Fix applied:

- added `karma-chrome-launcher`
- switched local Karma runs to Chrome headless instead of PhantomJS
- removed the obsolete `karma-phantomjs-launcher` dependency
- simplified the Karma config to use `ChromeHeadless` by default, with `TEST_BROWSER` available as an override

Current result:

- `npm test` passes
- 288 of 288 tests succeed in headless Chrome

Interpretation:

- the test corpus still has value
- the main issue was outdated execution infrastructure, not immediate behavioral failure

### 5. Demo viability

What I checked:

- `demo.html` expects `pkg/annotator.min.js`
- `dev.html` serves through `npm start`
- the dev page loads successfully in headless Chrome
- the dumped DOM shows Annotator CSS and UI elements injected into the page

Interpretation:

- the demo path is live again
- there is still room for more hands-on UX verification, but the basic browser integration path works

## What I Learned About How It Works

### App startup

`annotator.App` includes default modules for:

- authz
- identity
- storage

When `app.start()` runs, it binds utilities from the registry and creates `app.annotations` as a `StorageAdapter`.

### Annotation lifecycle

The UI module:

- listens for text selection
- serializes the selection into quote/range data
- opens editor UI
- calls `app.annotations.create`, `update`, or `delete`

The storage adapter:

- runs before/after hooks
- delegates to the chosen storage implementation
- updates the in-memory annotation object with the store response

The UI then:

- draws highlights on create/load
- redraws on update
- removes highlights on delete

### Persistence model

There is no single mandatory server inside this repo.

Instead, the storage contract is:

- local no-op/debug for development
- remote HTTP storage for real persistence

That separation is one of the strongest design choices in the codebase and should probably be preserved.

## Current Blockers

### Blocker 1: obsolete browser test configuration

The suite now runs, but the historical default was still:

- Karma `0.13`
- PhantomJS launcher
- old Sauce Labs browser matrix

That stack is not a credible long-term verification story. The repo now has a workable Chrome-based local path, but this needs cleanup and explicit support.

### Blocker 2: legacy dependency debt

The project still carries:

- large numbers of deprecated packages
- many reported vulnerabilities
- old Browserify/Karma-era tooling

The build works, but the maintenance surface is still poor.

### Blocker 3: missing current public home

The historical domain and website state are not trustworthy. That blocks clear project communication, though not technical recovery.

## Strengths

- clear modular architecture
- explicit storage abstraction
- non-trivial test suite
- useful demo shape already exists
- documentation is old but still informative

## Weaknesses

- deeply outdated toolchain
- deprecated dependencies throughout
- security debt in the npm tree
- no currently verified working build on a modern environment
- external backend story needs revalidation

## Bottom Line

This project does not look dead in the architectural sense. It looked stranded in an obsolete JavaScript toolchain, but the first recovery pass was enough to restore a working local baseline.

What is true now:

1. the bundle builds on modern Node
2. the test suite passes in headless Chrome
3. the dev page serves and loads in a real browser process

That moves the project from basic recovery into modernization work: simplify the runner setup, reduce dependency debt, verify real user flows more deeply, and define the supported backend/public-facing story.
