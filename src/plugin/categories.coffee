class Annotator.Plugin.Categories extends Annotator.Plugin
  
  events:
    'annotationCreated'     : 'setHighlights'
#     'annotationViewerShown' : 'setViewer'
   
    
    
  # The field element added to the Annotator.Editor wrapped in jQuery. Cached to
  # save having to recreate it everytime the editor is displayed.
  field: null

  # The input element added to the Annotator.Editor wrapped in jQuery. Cached to
  # save having to recreate it everytime the editor is displayed.
  input: null
  
  
  options:
    categories: {}
  


  constructor: (element, categories) -> 
    @options.categories = categories


  # Public: Initialises the plugin and adds custom fields to both the
  # annotator viewer and editor. The plugin also checks if the annotator is
  # supported by the current browser.
  #
  # Returns nothing.
  pluginInit: ->
    return unless Annotator.supported()

    i = 0
    
    for cat,color of @options.categories
      if i == 0
        isChecked = true
      else
        isChecked = false
      i = i + 1
      @field = @annotator.editor.addField({
        type: 'radio'
        label:  cat
        value: cat
        hl: color
        checked: isChecked
        load:   this.updateField
        submit: this.setAnnotationCat
      })

    @viewer = @annotator.viewer.addField({
      load: this.updateViewer
    })

    # Add a filter to the Filter plugin if loaded.
    if @annotator.plugins.Filter
      @annotator.plugins.Filter.addFilter
        label: 'Categories'
        property: 'category'
        isFiltered: Annotator.Plugin.Categories.filterCallback

    @input = $(@field).find(':input')
  
   setViewer: (viewer, annotations) ->
     v = viewer
  
  # set the highlights of the annotation here.
   setHighlights: (annotation) ->
    cat = annotation.category
    highlights = annotation.highlights

    if cat    
      for h in highlights
        h.className = h.className + ' ' + this.options.categories[cat]
        
        
      




  # Annotator.Editor callback function. Updates the radio buttons with the
  # category attached to the provided annotation.
  #
  # field      - The tags field Element containing the input Element.
  # annotation - An annotation object to be edited.
  #
  # Examples
  #
  #   field = $('<li><input /></li>')[0]
  #   plugin.updateField(field, {tags: ['apples', 'oranges', 'cake']})
  #   field.value # => Returns 'apples oranges cake'
  #
  # Returns nothing.
  updateField: (field, annotation) =>
    category = ''
    category = annotation.category if field.checked = 'checked'
    @input.val(category)

  # Annotator.Editor callback function. Updates the annotation field with the
  # data retrieved from the @input property.
  #
  # field      - The tags field Element containing the input Element.
  # annotation - An annotation object to be updated.
  #
  # Examples
  #
  #   annotation = {}
  #   field = $('<li><input value="cake chocolate cabbage" /></li>')[0]
  #
  #   plugin.setAnnotationTags(field, annotation)
  #   annotation.tags # => Returns ['cake', 'chocolate', 'cabbage']
  #
  # Returns nothing.
  setAnnotationCat: (field, annotation) =>
    # check if the radio button is checked
    if field.childNodes[0].checked
        annotation.category = field.childNodes[0].id



 #
 # Displays the category of the annotation when on the viewer
 #
  updateViewer: (field, annotation) ->
    field = $(field)

    if annotation.category?
      field.addClass('annotator-category').html(->
        string = $.map(annotation.category,(cat) ->
            '<span class="annotator-hl annotator-hl-' + annotation.category + '">' + Annotator.$.escape(cat).toUpperCase() + '</span>'
        ).join('')
      )
    else
      field.remove()
