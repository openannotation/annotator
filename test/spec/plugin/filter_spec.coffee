describe "Filter", ->
  plugin  = null
  element = null

  beforeEach ->
    element = $('<div />')
    annotator = {
      subscribe: jasmine.createSpy('Annotator#subscribe()')
    }
    plugin  = new Annotator.Plugin.Filter(element[0])
    plugin.annotator = annotator

  describe "events", ->
    filterElement = null

    beforeEach ->
      filterElement = $(plugin.html.filter)
      plugin.element.append(filterElement)

    it "should call Filter#_onFilterFocus when a filter input is focussed", ->
      spyOn(plugin, '_onFilterFocus')
      filterElement.find('input').focus()
      expect(plugin._onFilterFocus).toHaveBeenCalled()

    it "should call Filter#_onFilterBlur when a filter input is blurred", ->
      spyOn(plugin, '_onFilterBlur')
      filterElement.find('input').blur()
      expect(plugin._onFilterBlur).toHaveBeenCalled()

    it "should call Filter#_onFilterKeyup when a key is pressed in an input", ->
      spyOn(plugin, '_onFilterKeyup')
      filterElement.find('input').keyup()
      expect(plugin._onFilterKeyup).toHaveBeenCalled()

  describe "constructor", ->
    it "should have an empty filters array", ->
      expect(plugin.filters).toEqual([])

    it "should have an filter element wrapped in jQuery", ->
      expect(plugin.filter instanceof jQuery).toBe(true)
      expect(plugin.filter.length).toBe(1)

    it "should append the toolbar to the @options.appendTo selector", ->
      expect(plugin.element instanceof jQuery).toBe(true)
      expect(plugin.element.length).toBe(1)

      parent = $(plugin.options.appendTo)
      expect(plugin.element.parent()[0]).toBe(parent[0])

  describe "pluginInit", ->
    it "should call Filter#_setupListeners()", ->
      spyOn(plugin, '_setupListeners')
      plugin.pluginInit()
      expect(plugin._setupListeners).toHaveBeenCalled()

  describe "_setupListeners", ->
    it "should subscribe to all relevant events on the annotator", ->
      plugin._setupListeners()
      events = [
        'annotationsLoaded', 'annotationCreated',
        'annotationUpdated', 'annotationDeleted'
      ]
      for event in events
        expect(plugin.annotator.subscribe).toHaveBeenCalledWith(event, plugin.updateHighlights)

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
      expect(filter.element[0]).toBe(plugin.element.find('#annotator-filter-tags').parent()[0])

  describe "updateFilter", ->
    filter = null
    annotations = null

    beforeEach ->
      filter = {
        id: 'text'
        label: 'Annotation'
        property: 'text'
        element: $('<span><input value="ca" /></span>')
        annotations: [],
        isFiltered: jasmine.createSpy('filter.isFiltered()').andCallFake (value, text) ->
          text.indexOf('ca') != -1
      }
      annotations = [
        {text: 'cat'}
        {text: 'dog'}
        {text: 'car'}
      ]

      plugin.filters = {'text': filter}
      plugin.highlights = {
        map: jasmine.createSpy('map').andReturn(annotations)
      }

      spyOn(plugin, 'updateHighlights')
      spyOn(plugin, 'resetHighlights')
      spyOn(plugin, 'filterHighlights')

    it "should call Filter#updateHighlights()", ->
      plugin.updateFilter(filter)
      expect(plugin.updateHighlights).toHaveBeenCalled()

    it "should call Filter#resetHighlights()", ->
      plugin.updateFilter(filter)
      expect(plugin.resetHighlights).toHaveBeenCalled()

    it "should filter the cat and car annotations", ->
      plugin.updateFilter(filter)
      expect(filter.annotations).toEqual([
        annotations[0], annotations[2]
      ])

    it "should call Filter#filterHighlights()", ->
      plugin.updateFilter(filter)
      expect(plugin.filterHighlights).toHaveBeenCalled()

    it "should NOT call Filter#filterHighlights() if there is no input", ->
      filter.element.find('input').val('')
      plugin.updateFilter(filter)
      expect(plugin.filterHighlights).not.toHaveBeenCalled()

  describe "updateHighlights", ->
    beforeEach ->
      plugin.highlights = null
      spyOn(jQuery.prototype, 'init')
      plugin.updateHighlights()

    it "should fetch the highlights from the DOM", ->
      expect(jQuery.prototype.init.mostRecentCall.args[0]).toBe('.annotator-hl')

    it "should set the Filter#highlights property", ->
      expect(plugin.highlights).toBeTruthy()

  describe "filterHighlights", ->
    it "should hide all highlights not whitelisted by the filters", ->
      plugin.highlights = $('<span /><span /><span /><span /><span />')
      plugin.filters = {
        'one': {
          annotations: [
            {highlights: [plugin.highlights[0]]}
            {highlights: [plugin.highlights[1]]}
          ]
        }
        'two': {
          annotations: [
            {highlights: [plugin.highlights[4]]}
            {highlights: [plugin.highlights[1]]}
            {highlights: [plugin.highlights[2]]}
          ]
        }
      }
      div = $('<div>').append(plugin.highlights)
      plugin.filterHighlights()

      expect(div.find('.' + plugin.classes.hl.hide).length).toBe(1)

  describe "resetHighlights", ->
    it "should remove the filter-hide class from all highlights", ->
      plugin.highlights = $('<span /><span /><span />').addClass(plugin.classes.hl.hide)
      plugin.resetHighlights()
      expect(plugin.highlights.filter('.' + plugin.classes.hl.hide).length).toBe(0)

  describe "group: filter input actions", ->
    filterElement = null

    beforeEach ->
      filterElement = $(plugin.html.filter)
      plugin.element.append(filterElement)

    describe "_onFilterFocus", ->
      it "should add an active class to the element", ->
        plugin._onFilterFocus({
          target: filterElement.find('input')[0]
        })
        expect(filterElement.hasClass(plugin.classes.active)).toBe(true)

    describe "_onFilterBlur", ->
      it "should remove the active class from the element", ->
        filterElement.addClass(plugin.classes.active)
        plugin._onFilterBlur({
          target: filterElement.find('input')[0]
        })
        expect(filterElement.hasClass(plugin.classes.active)).toBe(false)

      it "should NOT remove the active class from the element if it has a value", ->
        filterElement.addClass(plugin.classes.active)
        plugin._onFilterBlur({
          target: filterElement.find('input').val('filtered')[0]
        })
        expect(filterElement.hasClass(plugin.classes.active)).toBe(true)

    describe "_onFilterKeyup", ->
      beforeEach ->
        plugin.filters = {'my-filter': {label: 'My Filter'}}
        spyOn(plugin, 'updateFilter')

      it "should call Filter#updateFilter() with the relevant filter", ->
        filterElement.attr('id', 'my-filter')
        plugin._onFilterKeyup({
          target: filterElement[0]
        })
        expect(plugin.updateFilter).toHaveBeenCalledWith(plugin.filters['my-filter'])

      it "should NOT call Filter#updateFilter() if no filter is found", ->
        plugin._onFilterKeyup({
          target: filterElement[0]
        })
        expect(plugin.updateFilter).not.toHaveBeenCalled()
