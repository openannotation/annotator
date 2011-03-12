class Annotator.Plugin.Filter extends Annotator.Plugin
  events:
    ".annotator-filter-property input focus":    "_onFilterFocus"
    ".annotator-filter-property input blur":     "_onFilterBlur"
    ".annotator-filter-property input keypress": "_onFilterKeypress"

  # Common classes used to change plugin state.
  classes:
    active:   'annotator-filter-active'
    hl:
      hide:   'annotator-hl-filtered'
      active: 'annotator-hl-active'

  # HTML templates for the plugin UI.
  html:
    element: """
             <div class="annotator-filter">
               <strong>Navigate:</strong>
               <span class="annotator-filter-navigation">
                 <button class="annotator-filter-previous">Previous</button>
                 <button class="annotator-filter-next">Next</button>
               </span>
               <strong>Filter by:</strong>
             </div>
             """
    filter:  """
             <span class="annotator-filter-property">
               <label></label>
               <input/>
             </span>
             """

  # Default options for the plugin.
  options:
    # A CSS selector or Element to append the plugin toolbar to.
    appendTo: 'body'

  # Public: Creates a new instance of the Filter plugin.
  #
  # element - The Annotator element (this is ignored by the plugin).
  # options - An Object literal of options.
  #
  # Examples
  #
  #   filter = new Annotator.Plugin.Filter(annotator.element)
  #
  # Returns a new instance of the Filter plugin.
  constructor: (element, options) ->
    # As most events for this plugin are relative to the toolbar which is
    # not inside the Annotator#Element we override the element property.
    # Annotator#Element can still be accessed via @annotator.element.
    element = $(@html.element).appendTo(@options.appendTo)

    super element, options
    @filter  = $(@html.filter)
    @filters = []

  # Public: Adds a filter to the toolbar. The filter must have both a label
  # and a property of an annotation object to filter on.
  #
  # options - An Object literal containing the filters options.
  #           label    - A public facing String to represent the filter.
  #           property - An annotation property String to filter on.
  #
  # Examples
  #
  #   # Set up a filter to filter on the annotation.user property.
  #   filter.addFilter({
  #     label: User,
  #     property: 'user'
  #   })
  #
  # Returns itself to allow chaining.
  addFilter: (options) ->
    filter = $.extend({
      label: ''
      property: ''
    }, options)

    filter.id = 'annotator-filter-' + filter.property
    filter.element = @filter.clone().appendTo(@element)
    filter.element.find('label')
      .html(filter.label)
      .attr('for', filter.id)
    filter.element.find('input')
      .attr({
        id: filter.id
        placeholder: 'Filter by ' + filter.label + '\u2026'
      })

    @filters[filter.id] = filter
    this

  # Updates the filter field on focus.
  #
  # event - A focus Event object.
  #
  # Returns nothing
  _onFilterFocus: (event) =>
    $(event.target).parent().addClass(@classes.active)

  # Updates the filter field on blur.
  #
  # event - A blur Event object.
  #
  # Returns nothing.
  _onFilterBlur: (event) =>
    unless event.target.value
      $(event.target).parent().removeClass(@classes.active)

  # Updates the filters.
  #
  # event - A keypress Event
  #
  # Returns nothing.
  _onFilterKeypress: (event) =>
    # Perform the filter.
