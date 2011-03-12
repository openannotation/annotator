describe "Filter", ->
  plugin  = null
  element = null

  beforeEach ->
    element = $('<div />')
    plugin  = new Annotator.Plugin.Filter(element[0])

  describe "constructor", ->
    it "should have an element property", ->
      expect(plugin.element[0]).toBe(element[0])
    
    it "should have an empty filters array", ->
      expect(plugin.filters).toEqual([])

    it "should have an filter element wrapped in jQuery", ->
      expect(plugin.filter instanceof jQuery).toBe(true)
      expect(plugin.filter.length).toBe(1)

    it "should append the toolbar to the @options.appendTo selector", ->
      expect(plugin.toolbar instanceof jQuery).toBe(true)
      expect(plugin.toolbar.length).toBe(1)

      parent = $(plugin.options.appendTo)
      expect(plugin.toolbar.parent()[0]).toBe(parent[0])

  describe "addFilter", ->
    filter = null

    beforeEach ->
      filter = {
        label: 'Tag',
        property: 'tags'
      }
      plugin.addFilter(filter)

    it "should add a filter object to Filter#plugins", ->
      expect(plugin.filters['annotator-filter-tags']).toBeTruthy()

    it "should append the html to Filter#toolbar", ->
      filter = plugin.filters['annotator-filter-tags']
      expect(filter.element[0]).toBe(plugin.toolbar.find('#annotator-filter-tags').parent()[0])
