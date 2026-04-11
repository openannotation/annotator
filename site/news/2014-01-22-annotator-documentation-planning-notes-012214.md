---
title: "Annotator Documentation Planning Notes (01/22/14)"
date: 2014-01-22
---

<div>

</div>

<span class="c2">Date: </span>January 22, 2014

<span class="c2">Attendees: </span>Nick Stenning, Andrew Magliozzi,
Jamie Folsom, Doug Schepers, Dan Whaley, Randall Leeds, Jake Hartnell,
et. al.

<span class="c2">Location:</span> <span class="c0"><a
href="https://www.google.com/url?q=https%3A%2F%2Funhangout.media.mit.edu%2Fh%2FAnnotator&amp;sa=D&amp;sntz=1&amp;usg=AFQjCNHkwLZUtFTNYBgcTJTAhbENwE_wEA"
class="c1">https://unhangout.media.mit.edu/h/Annotator</a></span>

# <span id="h.lxcrg27v3dat"></span>Agenda

- Update the agenda
- Discussion

<!-- -->

- See : <span class="c12"><a
  href="http://www.google.com/url?q=http%3A%2F%2Fannotator.readthedocs.org%2Fen%2Flatest%2F&amp;sa=D&amp;sntz=1&amp;usg=AFQjCNHHGxCqLYNiogqPxZi1oXBEUzdM4Q"
  class="c1">http://annotator.readthedocs.org/en/latest/</a></span>

<!-- -->

- Assign Todos

# <span id="h.9txx5tsbu2ny"></span>Discussion

- Process for writing docs (Nick and Randall?)

<!-- -->

- How is the documentation generated?
  <sup><a href="#cmnt1" id="cmnt_ref1">[a]</a></sup>

<!-- -->

- What aspects of the Annotator API docs need updating?

<!-- -->

- Plain english documentation about how how it works and how pieces work
  together.

<!-- -->

- Which other docs can we model? \[see “Docs we like” below\]
- How will we handle new storage and auth?

<!-- -->

- current docs: <span class="c17"><a
  href="https://www.google.com/url?q=https%3A%2F%2Fgithub.com%2Fokfn%2Fannotator%2Fwiki%2FStore-Plugin&amp;sa=D&amp;sntz=1&amp;usg=AFQjCNFkPr-KSejKqSCjk63-wQ1_MlkeCA"
  class="c1">Store Plugin</a></span> & <span class="c17"><a
  href="https://www.google.com/url?q=https%3A%2F%2Fgithub.com%2Fokfn%2Fannotator%2Fwiki%2FPermissions-Plugin&amp;sa=D&amp;sntz=1&amp;usg=AFQjCNF0Ej6Xpkgh_766afJvr47nXr0KIg"
  class="c1">Permissions Plugin</a></span>

<!-- -->

- Most hasn’t changed… names have changed a little as has plugin
  loading.  Authentication hasn’t changed yet and may not change before
  2.0.

<!-- -->

- How can we make the Annotator landing page better?
- What will developers need to know about Annotator 2.0?
- Question: GH-Pages branch, or Wiki? Pros/Cons?

<!-- -->

- use HG-Pages branch

<!-- -->

- Who should write the Outline/TOC?
- Should we use Hypothes.is to annotate the current docs?

<!-- -->

- Create a Hypothes.is account by downloading the Chrome extension at:
  <span class="c0"><a
  href="http://www.google.com/url?q=http%3A%2F%2Fhypothes.is%2Falpha&amp;sa=D&amp;sntz=1&amp;usg=AFQjCNF5MQVgp--Euo2RA8Rou0Jwcw91iw"
  class="c1">http://hypothes.is/alpha</a></span>
- And following the directions on the page

<!-- -->

- I Annotate 2014, Apr 3-4, Hack days Apr 5-6

# <span id="h.15vofc21sw7q"></span>Action Items

- @Nick - Hypothes.is on the docs
- @Nick - Import “reStructuredText - how does it work?”
  meta-documentation
- <span class="c18">Create a Docs branch</span>
- @Michael,Jamie - Review documentation for sanity, up-to-date-ness
- @AndrewM - Update links -- remove wiki markup and replace with rST
  links
- @Nick - Remove all reference to AnnotateIt from docs
- @Dan - Collect Annotator use-cases and demos

<!-- -->

- \[thanks for starting this already, @DanWhaley!!\]

<!-- -->

- annotatorjs.org

<!-- -->

- <span class="c2">DONE</span> @Nick,Andrew - set up <span class="c0"><a
  href="http://www.google.com/url?q=http%3A%2F%2Fdocs.annotator.org&amp;sa=D&amp;sntz=1&amp;usg=AFQjCNEUYLFBHoNn5G2v2XBSWgeueCAXxg"
  class="c1">annotatorjs.org</a></span><sup><a href="#cmnt2" id="cmnt_ref2">[b]</a></sup> to
  point to gh-pages
- @AndrewB - Create desired
  sitemap<sup><a href="#cmnt3" id="cmnt_ref3">[c]</a></sup>
- @AndrewM - update github pages content (switch to Jekyll)
- @Jake,Randall - Update appearance

<!-- -->

- <span class="c2">DONE</span> @Nick,AndrewM - docs.annotatorjs.org --
  point at RTD
- @Randall - API docs extraction
- <span class="c2">DONE </span>@Nick - Remove documentation from wiki
  and update to point to docs.annotatorjs.org
- can we migrate our google doc to our community / annotator-in-the-wild
  page?
- showcase projects with a page like this: <span class="c0"><a
  href="http://www.google.com/url?q=http%3A%2F%2Fbuiltwith.angularjs.org%2F&amp;sa=D&amp;sntz=1&amp;usg=AFQjCNH4m7qxcxUY31UNGeUTogrN2hfQ2g"
  class="c1">http://builtwith.angularjs.org/</a></span>
- Find and list existing Annotator plugins

<!-- -->

- Create plugins.annotatorjs.org

<!-- -->

- Where does annotator “live”? OKFN?
- Assemble FAQs from the mailing list
- Make an Annotator setup tutorial (screencast / gist / etc)

# <span id="h.81u3tp2lqxu"></span>Docs we like:

- Django - <span class="c0"><a
  href="https://www.google.com/url?q=https%3A%2F%2Fdocs.djangoproject.com%2Fen%2F&amp;sa=D&amp;sntz=1&amp;usg=AFQjCNFvLzQjuoUe0fKg_LyCUqyNuF6SPw"
  class="c1">https://docs.djangoproject.com/en/</a></span>

<!-- -->

- AngularJS - <span class="c0"><a
  href="http://www.google.com/url?q=http%3A%2F%2Fdocs.angularjs.org%2Fapi&amp;sa=D&amp;sntz=1&amp;usg=AFQjCNEq002RVdnQIWYysICg36evolDCug"
  class="c1">http://docs.angularjs.org/api</a></span>
- Bootstrap - <span class="c0"><a
  href="http://www.google.com/url?q=http%3A%2F%2Fgetbootstrap.com%2Fjavascript%2F&amp;sa=D&amp;sntz=1&amp;usg=AFQjCNGj7gx0xS9-qm_ReZrkVFr1PLbt3Q"
  class="c1">http://getbootstrap.com/javascript/</a></span>
- JQuery -

<!-- -->

- <span class="c0"><a
  href="http://www.google.com/url?q=http%3A%2F%2Flearn.jquery.com%2Fusing-jquery-core%2F&amp;sa=D&amp;sntz=1&amp;usg=AFQjCNF1ogiQoEZsS0xFieOO5rY7T1t_fw"
  class="c1">http://learn.jquery.com/using-jquery-core/</a></span>
- <span class="c0"><a
  href="http://www.google.com/url?q=http%3A%2F%2Flearn.jquery.com%2Fplugins%2F&amp;sa=D&amp;sntz=1&amp;usg=AFQjCNGKLKhBn7cw9NpmqK0FnZ9U0cjNxw"
  class="c1">http://learn.jquery.com/plugins/</a></span>

<!-- -->

- MongoDB CRUD Operations - <span class="c0"><a
  href="http://www.google.com/url?q=http%3A%2F%2Fdocs.mongodb.org%2Fmanual%2Fcrud%2F&amp;sa=D&amp;sntz=1&amp;usg=AFQjCNGFSOsE3TjQkCyaW8CG_qN62vbHPQ"
  class="c1">http://docs.mongodb.org/manual/crud/</a></span>
- Pyramid - <span class="c0"><a
  href="http://www.google.com/url?q=http%3A%2F%2Fdocs.pylonsproject.org%2Fen%2Flatest%2Fdocs%2Fpyramid.html&amp;sa=D&amp;sntz=1&amp;usg=AFQjCNFW6xc8IKDhKRsJDlx-hGkAkUtx8Q"
  class="c1">http://docs.pylonsproject.org/en/latest/docs/pyramid.html</a></span>

<div class="c4">

<a href="#cmnt_ref1" id="cmnt1">[a]</a><span class="c10">Good question.
I think we need documentor documentation. Short answer for you: "pip
install sphinx && cd doc/ && make html"</span>

</div>

<div class="c4">

<a href="#cmnt_ref2" id="cmnt2">[b]</a><span class="c10">Neat!</span>

</div>

<div class="c4">

<a href="#cmnt_ref3" id="cmnt3">[c]</a><span class="c10">Here's a draft:
https://docs.google.com/document/d/1AZMfHE6SPEIztNSNIXALxev5KO0qQfolwTxRt_f15Do/edit?usp=sharing</span>

</div>
