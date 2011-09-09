class Annotator.Plugin.Categories extends Annotator.Plugin
  
  events:
    'annotationCreated': 'setHighlights'
#     'annotationLoaded': 'annotationLoaded'
    
    
  # The field element added to the Annotator.Editor wrapped in jQuery. Cached to
  # save having to recreate it everytime the editor is displayed.
  field: null

  # The input element added to the Annotator.Editor wrapped in jQuery. Cached to
  # save having to recreate it everytime the editor is displayed.
  input: null

  # Public: Initialises the plugin and adds custom fields to both the
  # annotator viewer and editor. The plugin also checks if the annotator is
  # supported by the current browser.
  #
  # Returns nothing.
  pluginInit: ->
    return unless Annotator.supported()

    @field = @annotator.editor.addField({
      type: 'radio'
      label:  'Errata'
      value: 'errata'
      load:   this.updateField
      submit: this.setAnnotationCat
    })

    @field = @annotator.editor.addField({
      type: 'radio'
      label:  'Suggestion'
      value: 'suggestion'
      load:   this.updateField
      submit: this.setAnnotationCat
    })
 
    @field = @annotator.editor.addField({
      type: 'radio'
      label:  'Comment'
      value: 'comment'
      load:   this.updateField
      submit: this.setAnnotationCat
    })
 
    @annotator.viewer.addField({
      load: this.updateViewer
    })

    # Add a filter to the Filter plugin if loaded.
    if @annotator.plugins.Filter
      @annotator.plugins.Filter.addFilter
        label: 'Categories'
        property: 'category'
        isFiltered: Annotator.Plugin.Categories.filterCallback

    @input = $(@field).find(':input')
  
  
  # must set the highlights of the annotation here.
   setHighlights: (annotation) =>
    cat = annotation.category
    highlights = annotation.highlights
    
    for h in highlights
      switch (cat)
        when 'errata'   then h.className = h.className + ' annotator-hl-errata'
        when 'comment'   then h.className = h.className + ' annotator-hl-comment'
        when 'suggestion'   then h.className = h.className + ' annotator-hl-suggestion'
      console.log(h.className)




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
#   updateViewer: (field, annotation) ->
    
          
        

# Checks an input string of keywords against an array of tags. If the keywords
# match _all_ tags the function returns true. This should be used as a callback
# in the Filter plugin.
#
# input - A String of keywords from a input field.
#
# Examples
#
#   Tags.filterCallback('cat dog mouse', ['cat', 'dog', 'mouse']) //=> true
#   Tags.filterCallback('cat dog', ['cat', 'dog', 'mouse']) //=> true
#   Tags.filterCallback('cat dog', ['cat']) //=> false
#
# Returns true if the input keywords match all tags.
Annotator.Plugin.Tags.filterCallback = (input, tags = []) ->
  matches  = 0
  keywords = []
  if input
    keywords = input.split(/\s+/g)
    for keyword in keywords when tags.length
      matches += 1 for tag in tags when tag.indexOf(keyword) != -1

  matches == keywords.length
