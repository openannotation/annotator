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
    links = []

    # first grab link relations
    
    for link in $("link")
      l = $(link)
      href = l.attr('href')
      rel = l.attr('rel')
      type = l.attr('type')
      if rel in ["alternate", "canonical"]
        links.push(href: href, rel: rel, type: type)

    # look for google scholar links (pdf, doi)
    # I guess it's kind of a hack to express DOI identifiers as links 
    # but it's convenient :-D
   
    for meta in $("meta")
      name = $(meta).attr("name")
      content = $(meta).attr("content")

      if name == "citation_pdf_url" and content
        links.push(href: content, type: "application/pdf")

      if name == "citation_doi" and content
        doi = content
        if doi[0..3] != "doi:"
          doi = "doi:" + doi
        links.push(href: doi)

      if name == "dc.identifier" and content and content[0..3] == "doi:"
        links.push(href: content)
        
    return links
