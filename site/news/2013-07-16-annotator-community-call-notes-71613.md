---
title: "Annotator Community Call Notes (7/16/13)"
date: 2013-07-16
---

<span class="c1 c5">Attendees</span><span class="c1">: Andrew Magliozzi,
Nick Stenning, Anna Gerber, Kristof Csillag, Randall Leeds, Jamie
Folsom, Dan Whaley, Eric</span>

<span class="c1"></span>

## <span id="h.yo27r5cu5cds"></span>What's wrong now?

<span class="c1"></span>

<span class="c17">Nick’s annotator deck from Hypothes.is conference in
April 2013: </span><span class="c19"><a
href="https://www.google.com/url?q=https%3A%2F%2Fspeakerdeck.com%2Fnickstenning%2Fokf-annotator-technical-overview%2314&amp;sa=D&amp;sntz=1&amp;usg=AFQjCNGOGIYD8qr8y11pNswWHHTe3EBm8g"
class="c7">https://speakerdeck.com/nickstenning/okf-annotator-technical-overview#14</a></span>

<span class="c1"></span>

## <span id="h.d8crxk95o31o"></span>What’s done already?

<span class="c1">Nick’s changes so far (7/16/13):
</span><span class="c15"><a
href="https://www.google.com/url?q=https%3A%2F%2Fgithub.com%2Fokfn%2Fannotator%2Fcompare%2Fmaster...wip&amp;sa=D&amp;sntz=1&amp;usg=AFQjCNF3so1Q5GMhpSDLumdWiwepf_m7XQ"
class="c7">https://github.com/okfn/annotator/compare/master...wip</a></span>

- <span class="c1">Mostly around the store plugin and
  serialization</span>

<!-- -->

- <span class="c1">new annotation property:
   </span><span class="c16">\_local</span>

<!-- -->

- <span class="c1">A local storage object</span>
- <span class="c1">should we leverage JSON.stringify()’s support of the
  toJSON method to make this automatic? Or too much magic?</span>

<span class="c1"></span>

## <span id="h.ec7bx5iyixcf"></span>What do we want to change?

### <span id="h.xxpjocbfnk5z"></span>UI decoupling

- <span class="c1">Randall has some ideas and old code for this that may
  come in handy - suggests using DOM events</span>
- <span class="c1"> Anna has a few concerns about custom UI as well -
  for complex UIs, events may need to be attached to different element
  than annotation target (especially when there are multiple Annotator
  instances on a page)</span>
- <span class="c1">Nick worries about relying entirely on DOM events,
  which would cause problems with programmatic or command line
  actions</span>

<!-- -->

- <span class="c1">Ideally Annotator Core is simply a Database with the
  following calls:</span>

<!-- -->

- <span class="c1 c11">Create</span><span class="c1"> \|
  </span><span class="c1 c11">Update</span><span class="c1"> \|
  </span><span class="c1 c11">Delete</span><span class="c1"> \|
  </span><span class="c1 c11">Query</span>

<span class="c1 c5">        ACTION: Randall to dig out highlighter
extraction branch</span>

<span class="c1"></span>

### <span id="h.d4wvirg42s0p"></span>Storage

- <span class="c1">Currently the Store Plugin does everything</span>

<!-- -->

- <span class="c1">Headers, Serialization, etc.</span>
- <span class="c1 c5 c11">Registry</span><span class="c1"> (added to
  Annotator repo on 6/25/13): </span><span class="c15"><a
  href="https://www.google.com/url?q=https%3A%2F%2Fgithub.com%2Fokfn%2Fannotator%2Fblob%2F208498c36029b889e42b5c0734f6ef3485ea4954%2Fsrc%2Fregistry.coffee&amp;sa=D&amp;sntz=1&amp;usg=AFQjCNGe2g6HcMcAWIxGoaz8ajZ2MwhX6Q"
  class="c7">https://github.com/okfn/annotator/blob/208498c36029b889e42b5c0734f6ef3485ea4954/src/registry.coffee</a></span>

<!-- -->

- <span class="c1">We have two... er, three options</span>

<!-- -->

- <span class="c1">1) Advertise arbitrary meta-data to store plugins,
  which other plugins can add to</span>

<!-- -->

- <span class="c1">Such as Headers</span>

<!-- -->

- <span class="c1">2) This is not the concern of the store plugin</span>
- <span class="c1">3) Auth Plugin and Store Plugin should be combined
  (??)</span>

<span class="c1 c5 c11">Quorum Decision</span><span class="c1">: Death
of the Auth Plugin</span>

<span class="c1"></span>

<span class="c1">        </span><span class="c1 c5">ACTION: Nick to
merge WIP branch</span>

<span class="c1 c5">        ACTION: Anna to test LoreStore with WIP
branch</span>

<span class="c1 c5">        ACTION: Nick to merge Auth Plugin with new
Store plugin</span>

<span class="c1"> </span>

### <span id="h.nilk9uyk92xa"></span>Flexible matching

<span class="c1"></span>

<span class="c1 c5">Question</span><span class="c1">: What happens if an
annotation has multiple matches?</span>

- <span class="c1">Perhaps implement a ‘chain’ of matching plugins and
  ‘kill the chain’ if one finds a match</span>

<!-- -->

- <span class="c1">Default is ‘range && x-path’ but you could also run a
  ‘matcher plugin’</span>

<!-- -->

- <span class="c1">One matcher from the point of view of Annotator --
  but, just like the store plugin could be a wrapper around multiple
  stores, the matcher could be a wrapper around multiple matchers.
  Default matcher: XPath lookup.</span>

<span class="c1"></span>

<span class="c1">Hypothes.is has a working implementation of
</span><span class="c1 c5">Fuzzy
Matching</span><span class="c1">...</span>

- <span class="c1 c11">Goal</span><span class="c1">: issue a pull
  request to implement that code in Annotator Core</span>

<!-- -->

- <span class="c1 c11">Question</span><span class="c1">: How can we do
  this incrementally with test coverage and not breaking anything and
  remaining </span><span class="c1 c5">backward compatible with the
  existing reference store</span><span class="c1">?</span>

<!-- -->

- <span class="c1">Issue: Target v. Range in respective
  schemas...</span>

<span class="c1"></span>

<span class="c1 c5">ACTION: Kristof to extract Hypothes.is flexible
matching and submit PR</span>

<span class="c1"></span>

<span class="c1 c5">Potential Solution</span><span class="c1">: resolve
DOM-specific matching and export the resulting matched range as a
NormalizedRange in the \_local object so UI can rely on the anchored
range and be ignorant of the serialization</span>

<span class="c1"></span>

<a href="#" id="id.ejcygaiaakmj"></a>

<span class="c1 c5">Consideration: </span><span class="c1">Annotations
of ‘other’ media types, such as images or videos.  Jamie is curious
about how to maintain ease of development for plugins that match
annotations to non-textual objects.</span>

- <span class="c1">What must a developer do to make multimedia
  annotation possible?</span>
- <span class="c1">How can we make this as easy as possible for
  developers?</span>

<!-- -->

- <span class="c1">A data model like this (deprecating ‘Ranges’)
  ‘targets’ are just
  ‘</span><span class="c1 c11">types’</span><span class="c1">:</span>

<span class="c1">{</span>

<span class="c1">   ...</span>

<span class="c1">   "targets": \[</span>

<span class="c1">     {"selectors": \[{“type”: …}, {“type”: …}\],
...},</span>

<span class="c1">     {"selectors": \[{“type”: …}\], ...},</span>

<span class="c1">   \]</span>

<span class="c1">}</span>

<span class="c1">???</span>

<span class="c1 c5">ACTION Anna: write up this discussion and send
summary to mailing list</span>

### <span id="h.vv3jiocgvgh1"></span>Interplugin communication more generally

<span class="c1">Having plugins be usefully “pluggable” suggests that
the plugins should be registered and retrieved by name rather than
constructor. The store plugin is not \`Annotator.Plugins.Store\` but any
object which implements the appropriate interface and registers itself
as a ‘store’ plugin.</span>

<span class="c1"></span>

<span class="c1 c5">ACTION: Randall to remove all use of reference by
class (use string names instead) in plugin instantiation/config.</span>

### <span id="h.ce4licwr4xi0"></span>Removal and idempotence

<span class="c1">https://github.com/okfn/annotator/commit/cfbd11c903dc717eafc0cbeab5be800c3b5c7f1c</span>

### <span id="h.g8izkdbto471"></span>Other issues...

<span class="c1">        Release master as v1.2.8 and then merge WIP
branch. If we need a v1.2.9 then hotfix from master pre WIP
merge.</span>

<span class="c1"></span>

<span class="c1">Ballpark time to accomplish everything above: \_\_\_
Days, \_\_\_ Weeks, \_\_\_ Months</span>

<span class="c1"></span>

<span class="c1 c5">ACTION</span><span class="c1"> Jamie to pull master
(1.2.7) and build, integrate into a branch of Annotation Studio to test
\`Annotator#destroy()\`</span>

<span class="c1"></span>

## <span id="h.hupqvmbod4nr"></span>Proposals for improvement:

<span class="c1"></span>

### <span id="h.hj96sg4mfyh5"></span>Plugin types

<span class="c1"></span>

<span class="c1">1. Generic plugins</span>

<span class="c1">        </span>

### <span id="h.hgse6sbvafb2"></span>Groups Plugin

<span class="c1">        - The best solution for this is on the DB layer
by storing </span>

<span class="c1"></span>

### <span id="h.4cdg8y7cd9y6"></span>Sets Plugin

<span class="c1"></span>

<span class="c1">1. Store plugins</span>

<span class="c1"></span>

<span class="c1">2. Matcher plugins</span>

<span class="c1"></span>

### <span id="h.ulhkzzp937ce"></span>Asynchrony

<span class="c1"></span>

### <span id="h.8u9vb4p73g09"></span>Other ideas...

<span class="c1"></span>

## <span id="h.bc1ytb6596oh"></span>Who can help?  How?  When?

### <span id="h.s0qp9t1gb85"></span>Who is already working on these issues?

<span class="c1"></span>

### <span id="h.s6s123tot3ts"></span>Sharing innovation upstream

<span class="c1"></span>

### <span id="h.10og2klior3t"></span>Ownership, deliverables, & milestones

NEXT call: in one month...
