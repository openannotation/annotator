$ = require('./util').$

# Get xpath strings to the provided nodes relative to the provided root
#
# relativeRoot - A jQuery object of the nodes whose xpaths are requested.
#
# Returns Array[String]
simpleXPathJQuery = ($el, relativeRoot) ->
  jq = $el.map ->
    path = ''
    elem = this

    while elem?.nodeType == Node.ELEMENT_NODE and elem isnt relativeRoot
      tagName = elem.tagName.replace(":", "\\:")
      idx = $(elem.parentNode).children(tagName).index(elem) + 1

      idx  = "[#{idx}]"
      path = "/" + elem.tagName.toLowerCase() + idx + path
      elem = elem.parentNode

    path

  jq.get()

# Get xpath strings to the provided nodes relative to the provided root
#
# relativeRoot - A jQuery object of the nodes whose xpaths are requested.
#
# Returns Array[String]
simpleXPathPure = ($el, relativeRoot) ->

  getPathSegment = (node) ->
    name = getNodeName node
    pos = getNodePosition node
    "#{name}[#{pos}]"

  rootNode = relativeRoot

  getPathTo = (node) ->
    xpath = ''
    while node != rootNode
      unless node?
        throw new Error("Called getPathTo on a node which was not a descendant
                         of @rootNode. " + rootNode)
      xpath = (getPathSegment node) + '/' + xpath
      node = node.parentNode
    xpath = '/' + xpath
    xpath = xpath.replace /\/$/, ''
    xpath

  jq = $el.map ->
    path = getPathTo this

    path

  jq.get()

findChild = (node, type, index) ->
  unless node.hasChildNodes()
    throw new Error("XPath error: node has no children!")
  children = node.childNodes
  found = 0
  for child in children
    name = getNodeName child
    if name is type
      found += 1
      if found is index
        return child
  throw new Error("XPath error: wanted child not found.")

# Get the node name for use in generating an xpath expression.
getNodeName = (node) ->
  nodeName = node.nodeName.toLowerCase()
  switch nodeName
    when "#text" then return "text()"
    when "#comment" then return "comment()"
    when "#cdata-section" then return "cdata-section()"
    else return nodeName

# Get the index of the node as it appears in its parent's child list
getNodePosition = (node) ->
  pos = 0
  tmp = node
  while tmp
    if tmp.nodeName is node.nodeName
      pos += 1
    tmp = tmp.previousSibling
  pos

fromNode = ($el, relativeRoot) ->
  try
    result = simpleXPathJQuery $el, relativeRoot
  catch exception
    console.log("jQuery-based XPath construction failed! Falling back to
                 manual.")
    result = simpleXPathPure $el, relativeRoot
  result

# Public: Finds an Element Node using an XPath relative to the document root.
#
# If the document is served as application/xhtml+xml it will try and resolve
# any namespaces within the XPath.
#
# path - An XPath String to query.
#
# Examples
#
#   node = toNode('/html/body/div/p[2]')
#   if node
#     # Do something with the node.
#
# Returns the Node if found otherwise null.
toNode = (path, root = document) ->
  evaluateXPath = (xp, nsResolver = null) ->
    try
      document.evaluate(
        '.' + xp,
        root,
        nsResolver,
        XPathResult.FIRST_ORDERED_NODE_TYPE,
        null
      ).singleNodeValue
    catch exception
      # There are cases when the evaluation fails, because the
      # HTML documents contains nodes with invalid names,
      # for example tags with equal signs in them, or something like that.
      # In these cases, the XPath expressions will have these abominations,
      # too, and then they can not be evaluated.
      # In these cases, we get an XPathException, with error code 52.
      # See http://www.w3.org/TR/DOM-Level-3-XPath/xpath.html#XPathException
      # This does not necessarily make any sense, but this what we see
      # happening.
      console.log "XPath evaluation failed."
      console.log "Trying fallback..."
      # An 'evaluator' for the really simple expressions that
      # should work for the simple expressions we generate.
      steps = xp.substring(1).split("/")
      node = root
      for step in steps
        [name, idx] = step.split "["
        idx = if idx? then parseInt (idx?.split "]")[0] else 1
        node = findChild node, name.toLowerCase(), idx
      node

  if not $.isXMLDoc document.documentElement
    evaluateXPath path
  else
    # We're in an XML document, create a namespace resolver function to try
    # and resolve any namespaces in the current document.
    # https://developer.mozilla.org/en/DOM/document.createNSResolver
    customResolver = document.createNSResolver(
      if document.ownerDocument == null
        document.documentElement
      else
        document.ownerDocument.documentElement
    )
    node = evaluateXPath path, customResolver

    unless node
      # If the previous search failed to find a node then we must try to
      # provide a custom namespace resolver to take into account the default
      # namespace. We also prefix all node names with a custom xhtml namespace
      # eg. 'div' => 'xhtml:div'.
      path = (for segment in path.split '/'
        if segment and segment.indexOf(':') == -1
          segment.replace(/^([a-z]+)/, 'xhtml:$1')
        else segment
      ).join('/')

      # Find the default document namespace.
      namespace = document.lookupNamespaceURI null

      # Try and resolve the namespace, first seeing if it is an xhtml node
      # otherwise check the head attributes.
      customResolver  = (ns) ->
        if ns == 'xhtml' then namespace
        else document.documentElement.getAttribute('xmlns:' + ns)

      node = evaluateXPath path, customResolver
    node

module.exports =
  fromNode: fromNode
  toNode: toNode
