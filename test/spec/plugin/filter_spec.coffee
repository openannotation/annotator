describe "Filter", ->
  plugin  = null
  element = null

  beforeEach ->
    element = $('<div />')
    plugin  = new Annotator.Plugin.Filter(element[0])

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

    it "should call Filter#_onFilterKeypress when a key is pressed in an input", ->
      spyOn(plugin, '_onFilterKeypress')
      filterElement.find('input').keypress()
      expect(plugin._onFilterKeypress).toHaveBeenCalled()

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
