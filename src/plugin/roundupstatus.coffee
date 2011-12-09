class Annotator.Plugin.RoundupStatus extends Annotator.Plugin
  
  options:
    status : {}
  
  constructor: (element, status) -> 
    @options.status = status
    
  # Public: Initialises the plugin and adds custom fields to both the
  # annotator viewer and editor. The plugin also checks if the annotator is
  # supported by the current browser.
  #
  # Returns nothing.
  pluginInit: ->
    return unless Annotator.supported()

    @viewer = @annotator.viewer.addField({
      load: this.updateViewer
    })

    # Add a filter to the Filter plugin if loaded.
    if @annotator.plugins.Filter
      @annotator.plugins.Filter.addFilter
        label: 'Status'
        property: 'status'
        isFiltered: Annotator.Plugin.RoundupStatus.filterCallback

 # Shows status on editor
  updateViewer: (field, annotation) ->
    field = $(field)

    if annotation.issue_id?
      console.log(annotation.issue_id)
      field.addClass('annotator-status').html(->
        string = '<a href="http://0.0.0.0:8080/siyavulatracker/issue' + annotation.issue_id + '" target="_blank">See comments on Roundup!</a>'
      )
    else
      field.remove()
