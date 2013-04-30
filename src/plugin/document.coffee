class Annotator.Plugin.Document extends Annotator.Plugin

  $ = jQuery
  
  events:
    'beforeAnnotationCreated': 'beforeAnnotationCreated'

  pluginInit: ->
    @metadata = null

  beforeAnnotationCreated: (annotation) =>
    if not @metadata
      @metadata = this.getDocumentMetadata()
    annotation.document = @metadata

  getDocumentMetadata: =>
    @metadata =
      title: $("head title").text()
      link: this._getLinks()
    return @metadata

  _getLinks: =>
    # we know our current location is a link for the document
    links = [href: document.location.href]

    # TODO: get main url, as text/html

    # first grab link relations
    
    for link in $("link")
      l = $(link)
      href = _absoluteUrl(l.prop('href')) # get absolute url
      rel = l.prop('rel')
      type = l.prop('type')
      if rel in ["alternate", "canonical"]
        links.push(href: href, rel: rel, type: type)

    # look for google scholar links (pdf, doi)
    # 
    # I guess it's kind of a hack to express DOI identifiers as links 
    # but it's convenient, and somewhat sane if they don't have a type :-D
   
    for meta in $("meta")
      name = $(meta).attr("name")
      content = $(meta).attr("content")

      if name == "citation_pdf_url" and content
        links.push(href: _absoluteUrl(content), type: "application/pdf")

      if name == "citation_doi" and content
        doi = content
        if doi[0..3] != "doi:"
          doi = "doi:" + doi
        links.push(href: doi)

      if name == "dc.identifier" and content and content[0..3] == "doi:"
        links.push(href: content)
        
    return links
 
  # hack to get a absolute url from a possibly relative one
  
  _absoluteUrl = (url) ->
    img = $("<img src='#{ url }'>")
    url = img.prop('src')
    img.prop('src', null)
    return url

