class Annotator.Plugin.Filter extends Annotator.Plugin
  # Common classes used to change plugin state.
  classes: 
    active:   'annotator-filter-active'
    hl:
      hide:   'annotator-hl-filtered'
      active: 'annotator-hl-active'

  # HTML templates for the plugin UI.
  html: 
    toolbar: """
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
  # element - The Annotator element.
  # options - An Object literal of options.
  #
  # Examples
  #
  #   filter = new Annotator.Plugin.Filter(annotator.element)
  #
  # Returns a new instance of the Filter plugin.
  constructor: (element, options) ->
    super
    @toolbar = $(@html.toolbar).appendTo(@options.appendTo)
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
    filter.element = @filter.clone().appendTo(@toolbar)
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
