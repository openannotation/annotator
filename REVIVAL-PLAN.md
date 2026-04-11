# Annotator Revival Plan

This plan is based on the current hands-on assessment in `ASSESSMENT.md`.

## Goal

Get Annotator back to a state where:

- the library builds reproducibly
- tests provide meaningful signal
- the demo works in a modern browser
- the storage/backend story is clear
- contributors can understand where the project is headed

## Strategy

Do not start with a rewrite.

Start by recovering a trustworthy baseline on modern tooling. That recovery baseline now exists locally: the bundle builds, tests pass in Chrome, and the dev page loads. The next step is to consolidate that baseline into a clean, supported path.

## Phase 0: Stabilize The Assessment Environment

### Objective

Make the repo reproducible enough that further work is comparable from machine to machine.

### Actions

1. Document the exact current install workaround:
   - use a repo-local npm cache if the global cache is polluted
2. Record the exact Node/npm versions used during assessment
3. Decide whether the baseline target is:
   - modern Node only
   - or a pinned historical Node version in a container/worktree environment

### Recommended choice

Prefer a modern-Node baseline unless that quickly proves too expensive.

Reason:

- the first observed failure looks like a localized dependency compatibility issue, not total ecosystem collapse

## Phase 1: Consolidate Buildability

### Objective

Keep `pkg/annotator.js` and `pkg/annotator.min.js` building reproducibly on a supported modern environment.

### Current state

- a minimal compatibility fix is in place in `tools/cssify.js`
- CSS minification is now optional rather than a hard crash point

### Next actions

1. Decide whether to keep the fallback approach or replace it with a modern CSS minifier
2. Document the supported Node version for current development
3. Decide whether to commit `package-lock.json` as part of the stabilized baseline

### Success criteria

- `make pkg/annotator.min.js` stays green
- the build path is documented and intentional rather than accidental

## Phase 2: Modernize Test Signal

### Objective

Keep the tests running in a way that tells us whether the library still behaves correctly, without relying on dead browser infrastructure.

### Actions

1. Keep the existing test corpus
2. Treat PhantomJS as removed for practical purposes
3. Clean up the Karma configuration so Chrome is the explicit supported local default
4. Decide whether to stay on Karma temporarily or move to a more modern runner later

### Recommended approach

Preserve the tests first, modernize the runner second.

Reason:

- the test suite is one of the strongest assets in the repo
- rewriting tests too early throws away information

### Success criteria

- tests execute in supported modern headless browser(s)
- failures, if any, are about behavior rather than harness setup

## Phase 3: Deepen Demo And User-Flow Verification

### Objective

Confirm that the core user experience still works.

### Actions

1. Build the bundle
2. Run the local dev/demo path
3. Verify:
   - select text
   - create annotation
   - edit annotation
   - delete annotation
   - reload annotations using the available storage mode

### Initial target

Start with:

- `annotator.storage.noop` or `annotator.storage.debug`

Then move to:

- `annotator.storage.http`

### Success criteria

- the demo works locally for the basic annotation lifecycle
- basic UX verification is written down so it can be repeated

## Phase 4: Revalidate The Backend Story

### Objective

Decide what the supported persistence story should be.

### Actions

1. Inspect the historical `annotator-store` reference implementation
2. Decide whether to:
   - revive it
   - replace it
   - or specify the HTTP contract clearly and leave backend choice open
3. Confirm the minimum API needed for a modern working demo

### Recommended approach

Do not block client recovery on a full backend revival.

Instead:

- keep the storage contract explicit
- use the smallest backend needed for a working shared-annotation demo

## Phase 5: Improve Contributor Documentation

### Objective

Make the project understandable again for someone new.

### Actions

1. Keep `REBOOT.md` as the framing note
2. Maintain `INTRODUCTION.md` as the architecture overview
3. Maintain `ASSESSMENT.md` as the factual current-state report
4. Update `README.rst` once the practical path is clearer
5. Add modern local-development instructions after the build/test baseline is restored

## Phase 6: Re-establish Public Presence

### Objective

Give the project a trustworthy public home again.

### Actions

1. Choose a safe temporary canonical URL
2. Publish a minimal project page
3. Make status explicit:
   - historical project
   - revival in progress
   - current demo/build status

### Important constraint

Do this after technical recovery has started, not before.

Branding work should not displace build/test recovery.

## Recommended Immediate Next Steps

If I were continuing from this assessment, I would do these next:

1. Clean up and document the modern local dev/test path
2. Decide what to keep from the compatibility patches and what to replace properly
3. Inspect `annotator-store` and define the minimum backend needed for a live shared demo
4. Run a more explicit manual QA pass on selection, create, edit, delete, and reload
5. Start trimming dependency and tooling debt without rewriting the library

## Decision Gate After That

Once the above is done, decide between two paths:

1. Incremental modernization
   - preserve architecture
   - update toolchain, runner, packaging, and docs

2. Guided reboot
   - preserve product idea and data model
   - replace more of the implementation

Right now, the evidence favors incremental modernization first.
