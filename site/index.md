# Annotator

<section class="relative overflow-hidden rounded-3xl border border-stone-200 bg-gradient-to-br from-stone-950 via-slate-900 to-emerald-950 px-8 py-12 text-stone-50 shadow-2xl shadow-stone-950/20 md:px-12 md:py-16">
  <div class="absolute inset-0 bg-[radial-gradient(circle_at_top_left,_rgba(255,255,255,0.14),_transparent_32%),radial-gradient(circle_at_bottom_right,_rgba(16,185,129,0.22),_transparent_28%)]"></div>
  <div class="relative grid gap-10 lg:grid-cols-[1.15fr_0.85fr] lg:items-center">
    <div>
      <div class="mb-4 inline-flex items-center gap-2 rounded-full border border-emerald-300/30 bg-emerald-300/10 px-3 py-1 text-xs font-semibold uppercase tracking-[0.24em] text-emerald-200">
        Reboot In Progress
      </div>
      <h1 class="max-w-4xl text-4xl font-black tracking-tight text-white md:text-6xl">
        The collaborative annotation layer for the open web.
      </h1>
      <p class="mt-5 max-w-2xl text-lg leading-8 text-stone-200 md:text-xl">
        Annotator is an open-source JavaScript library for adding annotation functionality to web content: highlights, notes, metadata, storage, and shared discussion directly on top of documents.
      </p>
      <p class="mt-4 max-w-2xl text-base leading-7 text-stone-300">
        This project is being actively rebooted. The historical library, docs, and site content have been consolidated into one repository so the code, public site, and documentation can evolve together.
      </p>
      <div class="mt-8 flex flex-wrap gap-3">
        <a class="inline-flex items-center justify-center rounded-full bg-emerald-400 px-5 py-3 text-sm font-semibold text-stone-950 transition hover:bg-emerald-300" href="../docs/index.md">Read the docs</a>
        <a class="inline-flex items-center justify-center rounded-full border border-stone-300/30 px-5 py-3 text-sm font-semibold text-stone-100 transition hover:border-stone-100 hover:bg-stone-100/10" href="showcase.md">See the showcase</a>
        <a class="inline-flex items-center justify-center rounded-full border border-stone-300/30 px-5 py-3 text-sm font-semibold text-stone-100 transition hover:border-stone-100 hover:bg-stone-100/10" href="https://github.com/openannotation/annotator">View the code</a>
      </div>
    </div>
    <div class="relative">
      <div class="absolute -inset-5 rounded-[2rem] bg-emerald-400/20 blur-3xl"></div>
      <div class="relative overflow-hidden rounded-[2rem] border border-white/10 bg-stone-900/80 p-4 shadow-2xl">
        <img src="./assets/annotator-ui.png" alt="Historical Annotator interface screenshot" class="w-full rounded-2xl border border-white/10 shadow-lg" />
      </div>
    </div>
  </div>
</section>

<div class="mt-8 grid gap-4 md:grid-cols-4">
  <div class="rounded-2xl border border-stone-200 bg-white p-5 shadow-sm">
    <div class="text-sm font-semibold uppercase tracking-[0.2em] text-stone-500">What it does</div>
    <p class="mt-3 text-sm leading-6 text-stone-700">Turn any web page into an annotatable surface with highlights, comments, metadata, and UI components for creating and viewing annotations.</p>
  </div>
  <div class="rounded-2xl border border-stone-200 bg-white p-5 shadow-sm">
    <div class="text-sm font-semibold uppercase tracking-[0.2em] text-stone-500">How it works</div>
    <p class="mt-3 text-sm leading-6 text-stone-700">Browser-side UI and selection logic combined with pluggable identity, authorization, and storage modules.</p>
  </div>
  <div class="rounded-2xl border border-stone-200 bg-white p-5 shadow-sm">
    <div class="text-sm font-semibold uppercase tracking-[0.2em] text-stone-500">Why now</div>
    <p class="mt-3 text-sm leading-6 text-stone-700">There are still not many mature open-source annotation stacks. Annotator remains a credible base for revival.</p>
  </div>
  <div class="rounded-2xl border border-stone-200 bg-white p-5 shadow-sm">
    <div class="text-sm font-semibold uppercase tracking-[0.2em] text-stone-500">Project state</div>
    <p class="mt-3 text-sm leading-6 text-stone-700">Modern local build restored, tests running in headless Chrome, docs and site consolidated into the main repository.</p>
  </div>
</div>

## Why Annotator Still Matters

<div class="grid gap-6 lg:grid-cols-[0.95fr_1.05fr] lg:items-start">
  <div class="rounded-3xl border border-stone-200 bg-stone-50 p-7">
    <h2 class="text-2xl font-bold tracking-tight text-stone-900">A library, not just a demo</h2>
    <p class="mt-4 leading-7 text-stone-700">
      Annotator was used in real projects across education, publishing, research, and public knowledge. It was built around a clean separation between browser UI, annotation storage, and identity/authz concerns, which still makes architectural sense today.
    </p>
    <p class="mt-4 leading-7 text-stone-700">
      The reboot is not about preserving a relic. It is about recovering a serious open-source annotation system and putting it back on a maintainable footing.
    </p>
  </div>
  <div class="grid gap-4 sm:grid-cols-2">
    <figure class="overflow-hidden rounded-3xl border border-stone-200 bg-white shadow-sm">
      <img src="./assets/thumb-add.png" alt="Select text to add an annotation" class="w-full" />
      <figcaption class="px-4 py-3 text-sm text-stone-600">Select text to create an annotation.</figcaption>
    </figure>
    <figure class="overflow-hidden rounded-3xl border border-stone-200 bg-white shadow-sm">
      <img src="./assets/thumb-viewer.png" alt="View annotations on highlights" class="w-full" />
      <figcaption class="px-4 py-3 text-sm text-stone-600">View annotations directly in context.</figcaption>
    </figure>
    <figure class="overflow-hidden rounded-3xl border border-stone-200 bg-white shadow-sm">
      <img src="./assets/thumb-editor.png" alt="Annotation editor UI" class="w-full" />
      <figcaption class="px-4 py-3 text-sm text-stone-600">Edit comment text and metadata.</figcaption>
    </figure>
    <figure class="overflow-hidden rounded-3xl border border-stone-200 bg-white shadow-sm">
      <img src="./assets/thumb-bookmarklet.png" alt="Historical bookmarklet UI" class="w-full" />
      <figcaption class="px-4 py-3 text-sm text-stone-600">Historical reminder that Annotator aimed at the broader web, not only custom apps.</figcaption>
    </figure>
  </div>
</div>

## Explore

<div class="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
  <a href="../docs/index.md" class="group rounded-3xl border border-stone-200 bg-white p-6 shadow-sm transition hover:-translate-y-1 hover:shadow-lg">
    <div class="text-xs font-semibold uppercase tracking-[0.2em] text-emerald-700">Documentation</div>
    <h3 class="mt-3 text-xl font-bold text-stone-900">Technical docs</h3>
    <p class="mt-3 text-sm leading-6 text-stone-700">Installation, usage, modules, API reference, roadmap, and change history.</p>
    <div class="mt-4 text-sm font-semibold text-emerald-700">Open docs</div>
  </a>
  <a href="showcase.md" class="group rounded-3xl border border-stone-200 bg-white p-6 shadow-sm transition hover:-translate-y-1 hover:shadow-lg">
    <div class="text-xs font-semibold uppercase tracking-[0.2em] text-sky-700">Adoption</div>
    <h3 class="mt-3 text-xl font-bold text-stone-900">Showcase</h3>
    <p class="mt-3 text-sm leading-6 text-stone-700">See projects and organizations that historically used Annotator in the wild.</p>
    <div class="mt-4 text-sm font-semibold text-sky-700">View showcase</div>
  </a>
  <a href="plugins.md" class="group rounded-3xl border border-stone-200 bg-white p-6 shadow-sm transition hover:-translate-y-1 hover:shadow-lg">
    <div class="text-xs font-semibold uppercase tracking-[0.2em] text-amber-700">Ecosystem</div>
    <h3 class="mt-3 text-xl font-bold text-stone-900">Plugins</h3>
    <p class="mt-3 text-sm leading-6 text-stone-700">Browse the historical plugin catalog for integrations, storage backends, and UI extensions.</p>
    <div class="mt-4 text-sm font-semibold text-amber-700">Browse plugins</div>
  </a>
  <a href="news/index.md" class="group rounded-3xl border border-stone-200 bg-white p-6 shadow-sm transition hover:-translate-y-1 hover:shadow-lg">
    <div class="text-xs font-semibold uppercase tracking-[0.2em] text-rose-700">Archive</div>
    <h3 class="mt-3 text-xl font-bold text-stone-900">News and notes</h3>
    <p class="mt-3 text-sm leading-6 text-stone-700">Historical community updates, call notes, and project conversations imported from the old site.</p>
    <div class="mt-4 text-sm font-semibold text-rose-700">Read archive</div>
  </a>
</div>

## Repository

<div class="rounded-3xl border border-stone-200 bg-stone-950 px-7 py-8 text-stone-100">
  <h2 class="text-2xl font-bold tracking-tight text-white">One repository, one source of truth</h2>
  <p class="mt-4 max-w-3xl leading-7 text-stone-300">
    The library, public site content, and project documentation now live together. That makes it much easier to keep the technical story, public narrative, and reboot work in sync.
  </p>
  <div class="mt-6 flex flex-wrap gap-3">
    <a class="inline-flex items-center justify-center rounded-full bg-white px-5 py-3 text-sm font-semibold text-stone-950 transition hover:bg-stone-200" href="https://github.com/openannotation/annotator">Source code</a>
    <a class="inline-flex items-center justify-center rounded-full border border-white/20 px-5 py-3 text-sm font-semibold text-white transition hover:bg-white/10" href="https://github.com/openannotation/annotator/releases">Releases</a>
  </div>
</div>
