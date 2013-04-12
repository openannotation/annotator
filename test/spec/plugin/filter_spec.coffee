describe "Filter", ->
  plugin  = null
  element = null

  beforeEach ->
    element = $('<div />')
    annotator = {
      subscribe: sinon.spy()
      element: {
        find: sinon.stub().returns($())
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
      sinon.spy(plugin, '_onFilterFocus')
      filterElement.find('input').focus()
      assert(plugin._onFilterFocus.calledOnce)

    it "should call Filter#_onFilterBlur when a filter input is blurred", ->
      sinon.spy(plugin, '_onFilterBlur')
      filterElement.find('input').blur()
      assert(plugin._onFilterBlur.calledOnce)

    it "should call Filter#_onFilterKeyup when a key is pressed in an input", ->
      sinon.spy(plugin, '_onFilterKeyup')
      filterElement.find('input').keyup()
      assert(plugin._onFilterKeyup.calledOnce)

  describe "constructor", ->
    it "should have an empty filters array", ->
      assert.deepEqual(plugin.filters, [])

    it "should have an filter element wrapped in jQuery", ->
      assert.isTrue(plugin.filter instanceof jQuery)
      assert.lengthOf(plugin.filter, 1)

    it "should append the toolbar to the @options.appendTo selector", ->
      assert.isTrue(plugin.element instanceof jQuery)
      assert.lengthOf(plugin.element, 1)

      parent = $(plugin.options.appendTo)
      assert.equal(plugin.element.parent()[0], parent[0])

  describe "pluginInit", ->
    beforeEach ->
      sinon.stub(plugin, 'updateHighlights')
      sinon.stub(plugin, '_setupListeners').returns(plugin)
      sinon.stub(plugin, '_insertSpacer').returns(plugin)
      sinon.stub(plugin, 'addFilter')

    it "should call Filter#updateHighlights()", ->
      plugin.pluginInit()
      assert(plugin.updateHighlights.calledOnce)

    it "should call Filter#_setupListeners()", ->
      plugin.pluginInit()
      assert(plugin._setupListeners.calledOnce)

    it "should call Filter#_insertSpacer()", ->
      plugin.pluginInit()
      assert(plugin._insertSpacer.calledOnce)

    it "should load any filters in the Filter#options.filters array", ->
      filters = [
        {label: 'filter1'}
        {label: 'filter2'}
        {label: 'filter3'}
      ]

      plugin.options.filters = filters
      plugin.pluginInit()

      for filter in filters
        assert.isTrue(plugin.addFilter.calledWith(filter))

  describe "_setupListeners", ->
    it "should subscribe to all relevant events on the annotator", ->
      plugin._setupListeners()
      events = [
        'annotationsLoaded', 'annotationCreated',
        'annotationUpdated', 'annotationDeleted'
      ]
      for event in events
        assert.isTrue(plugin.annotator.subscribe.calledWith(event, plugin.updateHighlights))

  describe "addFilter", ->
    filter = null

    beforeEach ->
      filter = { label: 'Tag', property: 'tags' }
      plugin.addFilter(filter)

    it "should add a filter object to Filter#plugins", ->
      assert.ok(plugin.filters[0])

    it "should append the html to Filter#toolbar", ->
      filter = plugin.filters[0]
      assert.equal(filter.element[0], plugin.element.find('#annotator-filter-tags').parent()[0])

    it "should store the filter in the elements data store under 'filter'", ->
      filter = plugin.filters[0]
      assert.equal(filter.element.data('filter'), filter)

    it "should not add a filter for a property that has already been loaded", ->
      plugin.addFilter { label: 'Tag', property: 'tags' }
      assert.lengthOf(plugin.filters, 1)

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
        isFiltered: (value, text) ->
          text.indexOf('ca') != -1
      }
      annotations = [
        {text: 'cat'}
        {text: 'dog'}
        {text: 'car'}
      ]

      plugin.filters = {'text': filter}
      plugin.highlights = {
        map: -> annotations
      }

      sinon.stub(plugin, 'updateHighlights')
      sinon.stub(plugin, 'resetHighlights')
      sinon.stub(plugin, 'filterHighlights')

    it "should call Filter#updateHighlights()", ->
      plugin.updateFilter(filter)
      assert(plugin.updateHighlights.calledOnce)

    it "should call Filter#resetHighlights()", ->
      plugin.updateFilter(filter)
      assert(plugin.resetHighlights.calledOnce)

    it "should filter the cat and car annotations", ->
      plugin.updateFilter(filter)
      assert.deepEqual(filter.annotations, [
        annotations[0], annotations[2]
      ])

    it "should call Filter#filterHighlights()", ->
      plugin.updateFilter(filter)
      assert(plugin.filterHighlights.calledOnce)

    it "should NOT call Filter#filterHighlights() if there is no input", ->
      filter.element.find('input').val('')
      plugin.updateFilter(filter)
      assert.isFalse(plugin.filterHighlights.called)

  describe "updateHighlights", ->
    beforeEach ->
      plugin.highlights = null
      plugin.updateHighlights()

    it "should fetch the visible highlights from the Annotator#element", ->
      assert.isTrue(plugin.annotator.element.find.calledWith('.annotator-hl:visible'))

    it "should set the Filter#highlights property", ->
      assert.ok(plugin.highlights)

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
      assert.lengthOf(div.find('.' + plugin.classes.hl.hide), 4)

    it "should hide all highlights not whitelisted by _every_ filter if every filter is active", ->
      plugin.filters[1].annotations = []
      plugin.filterHighlights()

      assert.lengthOf(div.find('.' + plugin.classes.hl.hide), 3)

    it "should hide all highlights not whitelisted if only one filter", ->
      plugin.filters = plugin.filters.slice(0, 1)
      plugin.filterHighlights()

      assert.lengthOf(div.find('.' + plugin.classes.hl.hide), 3)

  describe "resetHighlights", ->
    it "should remove the filter-hide class from all highlights", ->
      plugin.highlights = $('<span /><span /><span />').addClass(plugin.classes.hl.hide)
      plugin.resetHighlights()
      assert.lengthOf(plugin.highlights.filter('.' + plugin.classes.hl.hide), 0)

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
        assert.isTrue(filterElement.hasClass(plugin.classes.active))

    describe "_onFilterBlur", ->
      it "should remove the active class from the element", ->
        filterElement.addClass(plugin.classes.active)
        plugin._onFilterBlur({
          target: filterElement.find('input')[0]
        })
        assert.isFalse(filterElement.hasClass(plugin.classes.active))

      it "should NOT remove the active class from the element if it has a value", ->
        filterElement.addClass(plugin.classes.active)
        plugin._onFilterBlur({
          target: filterElement.find('input').val('filtered')[0]
        })
        assert.isTrue(filterElement.hasClass(plugin.classes.active))

    describe "_onFilterKeyup", ->
      beforeEach ->
        plugin.filters = [{label: 'My Filter'}]
        sinon.stub(plugin, 'updateFilter')

      it "should call Filter#updateFilter() with the relevant filter", ->
        filterElement.data('filter', plugin.filters[0])
        plugin._onFilterKeyup({
          target: filterElement.find('input')[0]
        })
        assert.isTrue(plugin.updateFilter.calledWith(plugin.filters[0]))

      it "should NOT call Filter#updateFilter() if no filter is found", ->
        plugin._onFilterKeyup({
          target: filterElement.find('input')[0]
        })
        assert.isFalse(plugin.updateFilter.called)

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
        sinon.spy(plugin, '_scrollToHighlight')

      describe "_onNextClick", ->
        it "should advance to the next element", ->
          element2.addClass(plugin.classes.hl.active)
          plugin._onNextClick()
          assert.isTrue(plugin._scrollToHighlight.calledWith([element3[0]]))

        it "should loop back to the start once it gets to the end", ->
          element3.addClass(plugin.classes.hl.active)
          plugin._onNextClick()
          assert.isTrue(plugin._scrollToHighlight.calledWith([element1[0]]))

        it "should use the first element if there is no current element", ->
          plugin._onNextClick()
          assert.isTrue(plugin._scrollToHighlight.calledWith([element1[0]]))

        it "should only navigate through non hidden elements", ->
          element1.addClass(plugin.classes.hl.active)
          element2.addClass(plugin.classes.hl.hide)
          plugin._onNextClick()
          assert.isTrue(plugin._scrollToHighlight.calledWith([element3[0]]))

        it "should do nothing if there are no annotations", ->
          plugin.highlights = $()
          plugin._onNextClick()
          assert.isFalse(plugin._scrollToHighlight.called)

      describe "_onPreviousClick", ->
        it "should advance to the previous element", ->
          element3.addClass(plugin.classes.hl.active)
          plugin._onPreviousClick()
          assert.isTrue(plugin._scrollToHighlight.calledWith([element2[0]]))

        it "should loop to the end once it gets to the beginning", ->
          element1.addClass(plugin.classes.hl.active)
          plugin._onPreviousClick()
          assert.isTrue(plugin._scrollToHighlight.calledWith([element3[0]]))

        it "should use the last element if there is no current element", ->
          plugin._onPreviousClick()
          assert.isTrue(plugin._scrollToHighlight.calledWith([element3[0]]))

        it "should only navigate through non hidden elements", ->
          element3.addClass(plugin.classes.hl.active)
          element2.addClass(plugin.classes.hl.hide)
          plugin._onPreviousClick()
          assert.isTrue(plugin._scrollToHighlight.calledWith([element1[0]]))

        it "should do nothing if there are no annotations", ->
          plugin.highlights = $()
          plugin._onPreviousClick()
          assert.isFalse(plugin._scrollToHighlight.called)

    describe "_scrollToHighlight", ->
      mockjQuery = null

      beforeEach ->
        plugin.highlights = $()
        mockjQuery = {
          addClass: sinon.spy()
          animate: sinon.spy()
          offset: sinon.stub().returns({top: 0})
        }
        sinon.spy(plugin.highlights, 'removeClass')
        sinon.stub(jQuery.prototype, 'init').returns(mockjQuery)

      afterEach ->
        jQuery.prototype.init.restore()

      it "should remove active class from currently active element", ->
        plugin._scrollToHighlight({})
        assert.isTrue(plugin.highlights.removeClass.calledWith(plugin.classes.hl.active))

      it "should add active class to provided elements", ->
        plugin._scrollToHighlight({})
        assert.isTrue(mockjQuery.addClass.calledWith(plugin.classes.hl.active))

      it "should animate the scrollbar to the highlight offset", ->
        plugin._scrollToHighlight({})
        assert(mockjQuery.offset.calledOnce)
        assert(mockjQuery.animate.calledOnce)

    describe "_onClearClick", ->
      mockjQuery = null

      beforeEach ->
        mockjQuery = {}
        mockjQuery.val = sinon.stub().returns(mockjQuery)
        mockjQuery.prev = sinon.stub().returns(mockjQuery)
        mockjQuery.keyup = sinon.stub().returns(mockjQuery)
        mockjQuery.blur = sinon.stub().returns(mockjQuery)

        sinon.stub(jQuery.prototype, 'init').returns(mockjQuery)
        plugin._onClearClick({target: {}})

      afterEach ->
        jQuery.prototype.init.restore()

      it "should clear the input", ->
        assert.isTrue(mockjQuery.val.calledWith(''))

      it "should trigger the blur event", ->
        assert(mockjQuery.blur.calledOnce)

      it "should trigger the keyup event", ->
        assert(mockjQuery.keyup.calledOnce)
