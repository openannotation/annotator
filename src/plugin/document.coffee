Annotator = require('annotator')
$ = Annotator.Util.$

# isEmpty returns a boolean indicating whether the passed object is empty
isEmpty = (obj) ->
  # null and undefined objects are empty
  if not obj?
    return true

  for own k of obj
    return false

  return true


# absoluteUrl turns a possibly relative URL into an absolute one
absoluteUrl = (url) ->
  d = document.createElement('a')
  d.href = url
  d.href


getMetaTags = (prefix, attribute, delimiter) ->
  tags = {}
  for meta in $("meta")
    name = $(meta).attr(attribute)
    content = $(meta).prop("content")
    if name
      match = name.match(RegExp("^#{prefix}#{delimiter}(.+)$", "i"))
      if match
        n = match[1]
        if tags[n]
          tags[n].push(content)
        else
          tags[n] = [content]
  return tags


getHighwire = ->
  return getMetaTags("citation", "name", "_")


getFacebook = ->
  return getMetaTags("og", "property", ":")


getTwitter = ->
  return getMetaTags("twitter", "name", ":")


getDublinCore = ->
  return getMetaTags("dc", "name", ".")


getPrism = ->
  return getMetaTags("prism", "name", ".")


getEprints = ->
  return getMetaTags("eprints", "name", ".")


getFavicon = ->
  for link in $("link")
    if $(link).prop("rel") in ["shortcut icon", "icon"]
      return absoluteUrl(link.href)


getTitle = (d, keys) ->
  for k in keys
    if d[k]?.title?.length >= 1
      return d[k].title[0]

  # Fall back to document title
  return document.title


getLinks = ->
  # we know our current location is a link for the document
  results = [href: document.location.href]

  # look for some relevant link relations
  for link in $("link")
    l = $(link)
    rel = l.prop('rel')
    if rel not in ["alternate", "canonical", "bookmark"] then continue

    type = l.prop('type')
    lang = l.prop('hreflang')

    if rel is 'alternate'
      # Ignore feeds resources
      if type and type.match /^application\/(rss|atom)\+xml/ then continue
      # Ignore alternate languages
      if lang then continue

    href = absoluteUrl(l.prop('href')) # get absolute url

    results.push(href: href, rel: rel, type: type)

  return results


getHighwireLinks = (highwireMeta) ->
  results = []

  # look for links in scholar metadata
  for name, values of highwireMeta
    if name == "pdf_url"
      for url in values
        results.push
          href: absoluteUrl(url)
          type: "application/pdf"

    # kind of a hack to express DOI identifiers as links but it's a
    # convenient place to look them up later, and somewhat sane since
    # they don't have a type

    if name == "doi"
      for doi in values
        if doi[0..3] != "doi:"
          doi = "doi:" + doi
        results.push(href: doi)

  return results


getDublinCoreLinks = (dcMeta) ->
  results = []

  # look for links in dublincore data
  for name, values of dcMeta
    if name == "identifier"
      for id in values
        if id[0..3] == "doi:"
          results.push(href: id)

  return results


METADATA_FIELDS = {
  dc: getDublinCore
  eprints: getEprints
  facebook: getFacebook
  highwire: getHighwire
  prism: getPrism
  twitter: getTwitter
}


METADATA_TITLE_ORDER = [
  'highwire'
  'eprints'
  'prism'
  'facebook'
  'twitter'
  'dc'
]


getDocumentMetadata = ->
  out = {}

  # first look for some common metadata types
  # TODO: look for microdata/rdfa?
  for name, fetcher of METADATA_FIELDS
    result = fetcher()
    if !isEmpty(result)
      out[name] = result

  favicon = getFavicon()
  if favicon?
    out.favicon = favicon

  # extract out/normalize some things
  out.title = getTitle(out, METADATA_TITLE_ORDER)
  link = getLinks()
  if out.highwire?
    link = link.concat(getHighwireLinks(out.highwire))
  if out.dc?
    link = link.concat(getDublinCoreLinks(out.dc))
  if link.length > 0
    out.link = link

  return out


Document = (registry) ->
  metadata = getDocumentMetadata()

  return {
    onBeforeAnnotationCreated: (ann) ->
      # Assign a copy of the document metadata to the annotation
      ann.document = JSON.parse(JSON.stringify(metadata))
  }


Annotator.Plugin.Document = Document

exports.Document = Document
exports.absoluteUrl = absoluteUrl
exports.getDocumentMetadata = getDocumentMetadata
