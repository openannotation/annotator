class Annotator.Plugin.Categories extends Annotator.Plugin
  
  events:
    'annotationCreated'     : 'setHighlights'
    'annotationViewerShown' : 'setViewer'
#     'annotationLoaded': 'annotationLoaded'
    
    
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

    for cat,color of @options.categories
      console.log(cat, color)
        
      @field = @annotator.editor.addField({
        type: 'radio'
        label:  cat
        value: cat
        hl: color
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
     console.log(v)
     for a in annotations
        console.log(a)
  
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




  # Annotator.Viewer callback function. Updates the annotation display with tags
  # removes the field from the Viewer if there are no tags to display.
  #
  # field      - The Element to populate with tags.
  # annotation - An annotation object to be display.
  #
  # Examples
  #
  #   field = $('<div />')[0]
  #   plugin.updateField(field, {tags: ['apples']})
  #   field.innerHTML # => Returns '<span class="annotator-tag">apples</span>'
  #
  # Returns nothing.