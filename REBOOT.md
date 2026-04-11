---
created: 2026-04-11
---

# Annotator Reboot

This document is a working note for figuring out whether and how to revive Annotator. It captures the core framing for the reboot effort: the current situation, what makes it complicated, the key question to answer, and a first hypothesis about the cheapest sensible way forward. It also includes a lightweight appendix with the small amount of assessment work done so far.

Related working documents:

- [INTRODUCTION.md](./INTRODUCTION.md)
- [ASSESSMENT.md](./ASSESSMENT.md)
- [REVIVAL-PLAN.md](./REVIVAL-PLAN.md)

## SCQH

### Situation

This project has been unmaintained for about 11 years. It was originally used quite seriously, including by Hypothesis in its earlier history, and a lot of money and effort seems to have gone into making it high quality back in roughly the 2013 to 2017/18 period.

The core idea is still compelling: highlight text on a website or other piece of text, store that annotation somewhere, and make it viewable by others, so you get something like Google-Docs-style annotation on the web.

There do not seem to be many good open source annotation tools in this space, which makes this project potentially worth resurrecting.

### Complication

The project appears to have lost momentum and then been neglected. It is not clear what still works, whether the code is up to date, how the client JavaScript relates to any server-side storage, or what the current state of the website and documentation is.

On top of that, the original website/domain situation is messy: the historical project domain has been lost, and it is not yet clear what the right public home and naming should be going forward.

So the project needs some initial brushing off and tidying up before any bigger decision can be made.

### Question

Where are we, really?

More concretely:

- what is the current state of the code?
- how do the client, server, and annotation storage fit together?
- what still works?
- what is the cheapest sensible way to bring this back up to date?
- what should happen next?

### Hypothesis

The most sensible first move is not a rewrite. It is to do a light but disciplined assessment:

- understand the architecture
- work out what still functions
- identify the minimum viable path to a working modern demo
- sort out a basic website/home for the project

My guess is that the codebase is old but still contains a lot of useful product and architectural thinking, and that with a relatively modest amount of tidying and modernization it may be possible to resurrect it, or at least use it as the basis for a credible reboot.

## Appendix: Assessment

This is a lightweight assessment based on reading the repository and checking a few concrete facts. It is not yet a build/test/runtime assessment.

### What I have actually checked

- The directory currently has two main parts:
  - `annotator/` for the JavaScript library
  - `annotatorjs.org/` for the historical website
- The library identifies itself as `2.0.0-alpha.3` in `annotator/package.json`.
- The toolchain is old:
  - Node `>=0.10 <0.12`
  - jQuery `1.11`
  - Browserify
  - Karma/Mocha
  - PhantomJS
- The architecture appears modular:
  - the browser library handles selection/highlighting and annotation UI
  - `annotator.storage.http` expects a separate HTTP storage backend
  - identity and authorization are pluggable modules
- The historical project domain was `annotatorjs.org`.
- As of `2026-04-11`:
  - `annotatorjs.org` resolves, but no longer appears to be safely under project control
  - `annotatorjs.com` does not currently resolve
  - `openano.org` does not currently resolve
  - `annotatedjs.com` does not currently resolve

### What I have not checked yet

- whether `npm install` works
- whether tests pass
- whether the demo runs in a modern browser
- whether there is a usable historical server implementation outside this repo

### Provisional read

The project looks old, but not trivial or throwaway. The code and docs suggest a real browser annotation system with a separate storage API, not just a demo widget. The main uncertainty now is not whether the problem matters, but how expensive it will be to get this working again on a modern stack.

## Inbox

- [ ] ➕2026-04-11 annotator domain: historical project domain was `annotatorjs.org`, but it has expired / been lost and is now effectively squatted; `annotatorjs.com`, `openano.org`, and `annotatedjs.com` do not currently resolve, so we need to choose and register a new home domain.
