---
title: "Annotator Community Call Notes (9/27/13)"
date: 2013-09-27
---

<span class="c0">0. Attendees</span>

<span class="c4">Nick Stenning, Dan Whaley, Randall Leeds, Kristof
Csillag, Jamie Folsom, Andrew Magliozzi, Robert Casties, Phil Dessene,
Daniel Robles, Christian Kleinferchner, & Michael Scharf</span>

<span class="c0"></span>

<span class="c0">Notes from last time: </span><span class="c3 c12"><a
href="https://docs.google.com/a/finalsclub.org/document/d/1qYwTzTgRJbXid_3OY_th8bvP8ZEB-ACeQjAGjqQh6LY/edit"
class="c5">https://docs.google.com/a/finalsclub.org/document/d/1qYwTzTgRJbXid_3OY_th8bvP8ZEB-ACeQjAGjqQh6LY/edit</a></span>

<span class="c4"></span>

<span class="c6">+++ Annotator 2.0 Milestone</span>:

<span class="c3"><a
href="https://www.google.com/url?q=https%3A%2F%2Fgithub.com%2Fokfn%2Fannotator%2Fissues%3Fmilestone%3D3%26page%3D1%26state%3Dopen&amp;sa=D&amp;sntz=1&amp;usg=AFQjCNENLO0YROUroy6iG_kEiH9nPjpkLg"
class="c5">https://github.com/okfn/annotator/issues?milestone=3&amp;page=1&amp;state=open</a></span>

<span class="c0"></span>

<span class="c0">I. Action Items from Previous Call</span>

<span class="c0"></span>

<span class="c4">        </span><span class="c0 c9">Storage</span>

- <span class="c0">@Nick</span><span class="c4"> to merge WIP branch
  (</span><span class="c0">status = TBD )</span>

<!-- -->

- <span class="c0">Andrew & Nick working on fixing tests on WIP
  branch</span>
- <span class="c0">TODO: Next release of Annotator 1.2.8</span>

<!-- -->

- <span class="c0">@Anna</span><span class="c4"> to test LoreStore with
  WIP branch (</span><span class="c0">status =
  \_\_\_\_\_unknown\_\_\_\_\_ )</span>

<!-- -->

- <span class="c0">TODO: Andrew to follow up with Anna off list</span>

<!-- -->

- <span class="c0">@Nick</span><span class="c4"> to merge Auth Plugin
  with new Store plugin (</span><span class="c0">status = TBD )</span>

<!-- -->

- <span class="c0">Depends on rest of WIP branch</span>

<span class="c4">        </span><span class="c0 c9">User
Interface</span>

- <span class="c0">@Randall</span><span class="c4"> to dig out
  highlighter extraction branch (</span><span class="c0">status = not
  done)</span>

<span class="c4">        </span><span class="c0 c9">Flexible
Matching</span>

- <span class="c0">@csillag </span><span class="c4">to extract
  </span><span class="c3 c12"><a
  href="http://www.google.com/url?q=http%3A%2F%2Fhypothes.is%2F&amp;sa=D&amp;sntz=1&amp;usg=AFQjCNGA2H_uDkz9bPH5erbbEMXhQgO2kg"
  class="c5">Hypothes.is</a></span><span class="c4"> flexible matching
  and submit a pull request </span>

<!-- -->

- <span class="c4">strive to remain </span><span class="c0">backward
  compatible with the existing reference
  store</span><span class="c4"> by utilizing the new the \_local object
  so UI can rely on the anchored range regardless of the serialization
  (</span><span class="c0">status = TBD )</span>

<span class="c4">        </span><span class="c0 c9">Multimedia
Annotation</span>

- <span class="c0">@Anna</span><span class="c4"> to write up
  </span><span class="c3 c12"><a
  href="https://docs.google.com/a/finalsclub.org/document/d/1qYwTzTgRJbXid_3OY_th8bvP8ZEB-ACeQjAGjqQh6LY/edit#bookmark=id.ejcygaiaakmj"
  class="c5">this discussion</a></span><span class="c4"> and send a
  summary to the mailing list for further discussion
  (</span><span class="c0">status = TBD )</span>

<!-- -->

- <span class="c0">TODO: Andrew to follow up with Anna off list</span>

<span class="c4">        </span><span class="c0 c9">InterPlugin
Communication</span>

- <span class="c0">@Randall</span><span class="c4"> to remove all use of
  reference by class (use string names instead) in plugin
  instantiation/config. (</span><span class="c0">status = not
  done)</span>

<span class="c4"></span>

<span class="c4">        </span><span class="c0 c9">Other Issues</span>

- <span class="c0">@Jamie</span><span class="c4"> to pull master (1.2.7)
  and build, integrate into a branch of Annotation Studio to test
  \`Annotator#destroy()\` (</span><span class="c0">status = done
  )</span>

<!-- -->

- <span class="c0">Data store wasn’t returning a ‘204’ but is now fixed
  and this unblocks 1.2.8 release!</span>

<!-- -->

- <span class="c4">@</span><span class="c0">Andrew
  </span><span class="c4">Schedule another community call
  (</span><span class="c0">status = done!! )</span>
- <span class="c4">@</span><span class="c0">Everyone</span><span class="c4"> Stay
  tuned for build 1.2.8 release of Annotator in the near future
  (</span><span class="c0">status = Nick is all over this ASAP )</span>
- <span class="c0">Everyone </span><span class="c4">hang out in
  \#annotator on IRC (and if you don’t know how -- send an email to the
  mailing list).</span>

<span class="c6"></span>

<span class="c6">II. Discussion Items</span>

<span class="c6"></span>

        A. Annotator 2 as a Framework (continued from Dev List and
GitHub Issues)

- Branching / Forking and changing Annotator directly can be difficult
- Refactor to move UI out of core
- <span class="c3"><a
  href="http://www.google.com/url?q=http%3A%2F%2Flists.okfn.org%2Fpipermail%2Fannotator-dev%2F2013-June%2F000548.html&amp;sa=D&amp;sntz=1&amp;usg=AFQjCNEWBr82MRioukzkuhtBD9h9KXjvDg"
  class="c5">http://lists.okfn.org/pipermail/annotator-dev/2013-June/000548.html</a></span>
- <span class="c3"><a
  href="https://www.google.com/url?q=https%3A%2F%2Fspeakerdeck.com%2Fnickstenning%2Fokf-annotator-technical-overview&amp;sa=D&amp;sntz=1&amp;usg=AFQjCNGJckpN_RzKdBE8Os54Ad_xsVVPHA"
  class="c5">https://speakerdeck.com/nickstenning/okf-annotator-technical-overview</a></span>
- <span class="c6">Action Item</span>: Remove references by class

        B. New Plugins

- Open Video Annotation ( see <span class="c3"><a
  href="http://www.google.com/url?q=http%3A%2F%2Fwww.openvideoannotation.org&amp;sa=D&amp;sntz=1&amp;usg=AFQjCNFSkTYz4D_sW-InQabfPFusKi0JQQ"
  class="c5">http://www.openvideoannotation.org</a></span> )

<!-- -->

- Video.js
- Share without saving
- Rich Text Editing (w/ TinyMC Editor)
- Location via user IP address tracking
- Replies / Comments (Hypothes.is does this.  Is there a plugin
  already?)

<!-- -->

- Hypothes.is threading plugin -- no UI out of the box
  <span class="c3"><a
  href="https://www.google.com/url?q=https%3A%2F%2Fgithub.com%2Fhypothesis%2Fh%2Fblob%2Fmaster%2Fh%2Fjs%2Fplugin%2Fthreading.coffee&amp;sa=D&amp;sntz=1&amp;usg=AFQjCNG2gV_vq9Hh6gM9PArvQ63F8d3WCA"
  class="c5">https://github.com/hypothesis/h/blob/master/h/js/plugin/threading.coffee</a></span>
- Requires <span class="c3"><a
  href="https://www.google.com/url?q=https%3A%2F%2Fgithub.com%2Fmaxogden%2FconversationThreading-js&amp;sa=D&amp;sntz=1&amp;usg=AFQjCNFnaHYbNdxGGX-HFdnAnA4zNflQhA"
  class="c5">https://github.com/maxogden/conversationThreading-js</a></span>

<!-- -->

- Rubrics / Multiple-choice quizzes

<!-- -->

- Data Visualization (see <span class="c3"><a
  href="https://www.google.com/url?q=https%3A%2F%2Fosc.hul.harvard.edu%2Fhighbrow%2F&amp;sa=D&amp;sntz=1&amp;usg=AFQjCNFRQmofK1xpDCABcc3NfouUJGoSeg"
  class="c5">https://osc.hul.harvard.edu/highbrow/</a></span> )

C. Groups as core or plugin?

- <span class="c3"><a
  href="https://www.google.com/url?q=https%3A%2F%2Fgithub.com%2Fhyperstudio%2FAnnotation-Studio%2Fwiki%2FHow-we-implement-groups-functionality&amp;sa=D&amp;sntz=1&amp;usg=AFQjCNENjtXsHwjppNq6n3r_DYrBEzdWXA"
  class="c5">https://github.com/hyperstudio/Annotation-Studio/wiki/How-we-implement-groups-functionality</a></span>
- See also: <span class="c3"><a
  href="https://www.google.com/url?q=https%3A%2F%2Fgithub.com%2Fokfn%2Fannotator%2Fwiki%2FPermissions-Plugin&amp;sa=D&amp;sntz=1&amp;usg=AFQjCNF0Ej6Xpkgh_766afJvr47nXr0KIg"
  class="c5">https://github.com/okfn/annotator/wiki/Permissions-Plugin</a></span>
- Hypothes.is Groups Document: <span class="c3"><a
  href="https://docs.google.com/a/finalsclub.org/document/d/17HDaujAt5P9o5x2Yinr8jL_tZS_3Zd36VBYbpPz-bkM/edit"
  class="c5">https://docs.google.com/a/finalsclub.org/document/d/17HDaujAt5P9o5x2Yinr8jL_tZS_3Zd36VBYbpPz-bkM/edit</a></span>

        Some stuff from MPIWG

                Annotation server based on Neo4J, digilib plugin etc:
<span class="c3"><a
href="https://www.google.com/url?q=https%3A%2F%2Fit-dev.mpiwg-berlin.mpg.de%2Ftracs%2FAnnotations%2F&amp;sa=D&amp;sntz=1&amp;usg=AFQjCNGeQE5ci5kC91_9CsGDzv4Jzm2qew"
class="c5">https://it-dev.mpiwg-berlin.mpg.de/tracs/Annotations/</a></span>

                example text annotation: <span class="c3"><a
href="http://www.google.com/url?q=http%3A%2F%2Flibcoll.mpiwg-berlin.mpg.de%2Flibviewa%3Furl%3Dexperimental%252Fdigilib-test%252Fbenedetti-1585%26pn%3D5%26viewLayer%3Dannotator&amp;sa=D&amp;sntz=1&amp;usg=AFQjCNFAHXgCIzyoNV6DM95nXlOP8z2Xxw"
class="c5">http://libcoll.mpiwg-berlin.mpg.de/libviewa?url=experimental%2Fdigilib-test%2Fbenedetti-1585&amp;pn=5&amp;viewLayer=annotator</a></span>

                example image annotation: <span class="c3"><a
href="http://www.google.com/url?q=http%3A%2F%2Flibcoll.mpiwg-berlin.mpg.de%2Flibviewa%3Furl%3Dexperimental%2Fdigilib-test%2Fbenedetti-1585%26viewMode%3Dimage%26pn%3D5%26viewLayer%3Dannotator&amp;sa=D&amp;sntz=1&amp;usg=AFQjCNF65iQpiha3U7sDI9XqfmLlwvpSFA"
class="c5">http://libcoll.mpiwg-berlin.mpg.de/libviewa?url=experimental/digilib-test/benedetti-1585&amp;viewMode=image&amp;pn=5&amp;viewLayer=annotator</a></span>

<span class="c6">III. Next Steps and Other Action Items</span>

<span class="c6"></span>

<span class="c6">        @Andrew, @Jamie, & @Dan TODO:
</span>assemble/update master list of Annotator plugins, integrations
and projects -- on the annotator website (github.io).

                <span class="c6">Blocker: @Nick </span>to get github
page ready for us to edit

        <span class="c6">@Randall</span>: heatmap demo / contribution
with vanilla annotator

        <span class="c6">@Andrew: </span>Follow up with Anna off list

        <span class="c6">Everybody:</span> Annotator 2.0 Milestone:

<span class="c3"><a
href="https://www.google.com/url?q=https%3A%2F%2Fgithub.com%2Fokfn%2Fannotator%2Fissues%3Fmilestone%3D3%26page%3D1%26state%3Dopen&amp;sa=D&amp;sntz=1&amp;usg=AFQjCNENLO0YROUroy6iG_kEiH9nPjpkLg"
class="c5">https://github.com/okfn/annotator/issues?milestone=3&amp;page=1&amp;state=open</a></span>

<span class="c6">@Nick</span>: people were at OKcon who were interested
in annotation.

<span class="c6">@Nick</span>: Adam Green: offered a pro-bono
facilitation of documentation for annotator.
