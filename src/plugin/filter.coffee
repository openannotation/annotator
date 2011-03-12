class Annotator.Plugin.Filter extends Annotator.Plugin
  classes: 
    active:   'annotator-filter-active'
    hl:
      hide:   'annotator-hl-filtered'
      active: 'annotator-hl-active'

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
               <label for="annotator-filter-{property}">{label}</label>
               <input id="annotator-filter-{property}" placeholder="Filter by {label}&hellip;" />
             </span>
            """

  options:
    appendTo: 'body'

  constructor: (element, options) ->
    super
    @toolbar = $(@html.toolbar).appendTo(@options.appendTo)
    @filter  = $(@html.filter)
    @filters = []
