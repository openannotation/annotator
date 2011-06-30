describe "Filter", ->
  plugin  = null
  element = null

  beforeEach ->
    element = $('<div />')
    annotator = {
      subscribe: jasmine.createSpy('Annotator#subscribe()')
      element: {
        find: jasmine.createSpy('element#find()').andReturn($())
      }
    }
    plugin = new Annotator.Plugin.Filter(element[0])
    plugin.annotator = annotator

  afterEach ->
    plugin.element.remove()

  describe "events", ->
    filterElement = null

    beforeEach ->
      filterElement = $(plugin.html.filter)
      plugin.element.append(filterElement)

    afterEach ->
      filterElement.remove()

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
    beforeEach ->
      spyOn(plugin, 'updateHighlights')
      spyOn(plugin, '_setupListeners').andReturn(plugin)
      spyOn(plugin, '_insertSpacer').andReturn(plugin)
      spyOn(plugin, 'addFilter')

    it "should call Filter#updateHighlights()", ->
      plugin.pluginInit()
      expect(plugin.updateHighlights).toHaveBeenCalled()

    it "should call Filter#_setupListeners()", ->
      plugin.pluginInit()
      expect(plugin._setupListeners).toHaveBeenCalled()
      
    it "should call Filter#_insertSpacer()", ->
      plugin.pluginInit()
      expect(plugin._insertSpacer).toHaveBeenCalled()

    it "should load any filters in the Filter#options.filters array", ->
      filters = [
        {label: 'filter1'}
        {label: 'filter2'}
        {label: 'filter3'}
      ]

      plugin.options.filters = filters
      plugin.pluginInit()

      for filter in filters
        expect(plugin.addFilter).toHaveBeenCalledWith(filter)

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
      filter = { label: 'Tag', property: 'tags' }
      plugin.addFilter(filter)

    it "should add a filter object to Filter#plugins", ->
      expect(plugin.filters[0]).toBeTruthy()

    it "should append the html to Filter#toolbar", ->
      filter = plugin.filters[0]
      expect(filter.element[0]).toBe(plugin.element.find('#annotator-filter-tags').parent()[0])

    it "should store the filter in the elements data store under 'filter'", ->
      filter = plugin.filters[0]
      expect(filter.element.data('filter')).toBe(filter)

    it "should not add a filter for a property that has already been loaded", ->
      plugin.addFilter { label: 'Tag', property: 'tags' }
      expect(plugin.filters.length).toBe(1)

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
      plugin.updateHighlights()

    it "should fetch the visible highlights from the Annotator#element", ->
      expect(plugin.annotator.element.find).toHaveBeenCalledWith('.annotator-hl:visible')

    it "should set the Filter#highlights property", ->
      expect(plugin.highlights).toBeTruthy()

  describe "filterHighlights", ->
    div = null

    beforeEach ->
      plugin.highlights = $('<span /><span /><span /><span /><span />')

      # This annotation appears in both filters.
      match = {highlights: [plugin.highlights[1]]}
      plugin.filters = [
        {
          annotations: [
            {highlights: [plugin.highlights[0]]}
            match
          ]
        }
        {
          annotations: [
            {highlights: [plugin.highlights[4]]}
            match
            {highlights: [plugin.highlights[2]]}
          ]
        }
      ]
      div = $('<div>').append(plugin.highlights)

    it "should hide all highlights not whitelisted by _every_ filter", ->
      plugin.filterHighlights()

      #Only index 1 should remain.
      expect(div.find('.' + plugin.classes.hl.hide).length).toBe(4)

    it "should hide all highlights not whitelisted by _every_ filter if every filter is active", ->
      plugin.filters[1].annotations = []
      plugin.filterHighlights()

      expect(div.find('.' + plugin.classes.hl.hide).length).toBe(3)

    it "should hide all highlights not whitelisted if only one filter", ->
      plugin.filters = plugin.filters.slice(0, 1)
      plugin.filterHighlights()

      expect(div.find('.' + plugin.classes.hl.hide).length).toBe(3)

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
        plugin.filters = [{label: 'My Filter'}]
        spyOn(plugin, 'updateFilter')

      it "should call Filter#updateFilter() with the relevant filter", ->
        filterElement.data('filter', plugin.filters[0])
        plugin._onFilterKeyup({
          target: filterElement.find('input')[0]
        })
        expect(plugin.updateFilter).toHaveBeenCalledWith(plugin.filters[0])

      it "should NOT call Filter#updateFilter() if no filter is found", ->
        plugin._onFilterKeyup({
          target: filterElement.find('input')[0]
        })
        expect(plugin.updateFilter).not.toHaveBeenCalled()

    describe "navigation", ->
      element1    = null
      element2    = null
      element3    = null
      annotation1 = null
      annotation2 = null
      annotation3 = null

      beforeEach ->
        element1    = $('<span />')
        annotation1 = {text: 'annotation1', highlights: [element1[0]]}
        element1.data('annotation', annotation1)

        element2    = $('<span />')
        annotation2 = {text: 'annotation2', highlights: [element2[0]]}
        element2.data('annotation', annotation2)

        element3    = $('<span />')
        annotation3 = {text: 'annotation3', highlights: [element3[0]]}
        element3.data('annotation', annotation3)

        plugin.highlights = $([element1[0],element2[0],element3[0]])
        spyOn(plugin, '_scrollToHighlight')

      describe "_onNextClick", ->
        it "should advance to the next element", ->
          element2.addClass(plugin.classes.hl.active)
          plugin._onNextClick()
          expect(plugin._scrollToHighlight).toHaveBeenCalledWith([element3[0]])

        it "should loop back to the start once it gets to the end", ->
          element3.addClass(plugin.classes.hl.active)
          plugin._onNextClick()
          expect(plugin._scrollToHighlight).toHaveBeenCalledWith([element1[0]])

        it "should use the first element if there is no current element", ->
          plugin._onNextClick()
          expect(plugin._scrollToHighlight).toHaveBeenCalledWith([element1[0]])

        it "should only navigate through non hidden elements", ->
          element1.addClass(plugin.classes.hl.active)
          element2.addClass(plugin.classes.hl.hide)
          plugin._onNextClick()
          expect(plugin._scrollToHighlight).toHaveBeenCalledWith([element3[0]])

        it "should do nothing if there are no annotations", ->
          plugin.highlights = $()
          plugin._onNextClick()
          expect(plugin._scrollToHighlight).not.toHaveBeenCalled()

      describe "_onPreviousClick", ->
        it "should advance to the previous element", ->
          element3.addClass(plugin.classes.hl.active)
          plugin._onPreviousClick()
          expect(plugin._scrollToHighlight).toHaveBeenCalledWith([element2[0]])

        it "should loop to the end once it gets to the beginning", ->
          element1.addClass(plugin.classes.hl.active)
          plugin._onPreviousClick()
          expect(plugin._scrollToHighlight).toHaveBeenCalledWith([element3[0]])

        it "should use the last element if there is no current element", ->
          plugin._onPreviousClick()
          expect(plugin._scrollToHighlight).toHaveBeenCalledWith([element3[0]])

        it "should only navigate through non hidden elements", ->
          element3.addClass(plugin.classes.hl.active)
          element2.addClass(plugin.classes.hl.hide)
          plugin._onPreviousClick()
          expect(plugin._scrollToHighlight).toHaveBeenCalledWith([element1[0]])

        it "should do nothing if there are no annotations", ->
          plugin.highlights = $()
          plugin._onPreviousClick()
          expect(plugin._scrollToHighlight).not.toHaveBeenCalled()

    describe "_scrollToHighlight", ->
      mockjQuery = null

      beforeEach ->
        plugin.highlights = $()
        mockjQuery = {
          addClass: jasmine.createSpy('jQuery#addClass()')
          animate: jasmine.createSpy('jQuery#animate()')
          offset: jasmine.createSpy('jQuery#offset()').andReturn({top: 0})
        }
        spyOn(plugin.highlights, 'removeClass')
        spyOn(jQuery.prototype, 'init').andReturn(mockjQuery)

      it "should remove active class from currently active element", ->
        plugin._scrollToHighlight({})
        expect(plugin.highlights.removeClass).toHaveBeenCalledWith(plugin.classes.hl.active)

      it "should add active class to provided elements", ->
        plugin._scrollToHighlight({})
        expect(mockjQuery.addClass).toHaveBeenCalledWith(plugin.classes.hl.active)

      it "should animate the scrollbar to the highlight offset", ->
        plugin._scrollToHighlight({})
        expect(mockjQuery.offset).toHaveBeenCalled()
        expect(mockjQuery.animate).toHaveBeenCalled()

    describe "_onClearClick", ->
      mockjQuery = null

      beforeEach ->
        mockjQuery = {}
        mockjQuery.val = jasmine.createSpy().andReturn(mockjQuery)
        mockjQuery.prev = jasmine.createSpy().andReturn(mockjQuery)
        mockjQuery.keyup = jasmine.createSpy().andReturn(mockjQuery)
        mockjQuery.blur = jasmine.createSpy().andReturn(mockjQuery)

        spyOn($.prototype, 'init').andReturn(mockjQuery)
        plugin._onClearClick({target: {}})

      it "should clear the input", ->
        expect(mockjQuery.val).toHaveBeenCalledWith('')

      it "should trigger the blur event", ->
        expect(mockjQuery.blur).toHaveBeenCalled()

      it "should trigger the keyup event", ->
        expect(mockjQuery.keyup).toHaveBeenCalled()
