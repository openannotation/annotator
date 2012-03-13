class Annotator.Plugin.Comment extends Annotator.Plugin
  events:
    'annotationViewerShown' : 'addReplyButton'
    '.annotator-reply click': 'onReplyClick'
    '.annotator-reply-entry click': 'onReplyEntryClick'
    

  constructor: (element) ->
      super

    
  # Public: Initialises the plugin and adds custom fields to both the
  # annotator viewer and editor. The plugin also checks if the annotator is
  # supported by the current browser.
  #
  # Returns nothing.
  pluginInit: ->
    return unless Annotator.supported()
    console.log('loaded Comment plugin')


  addReplyButton: (viewer, annotations) ->
    console.log('addReplyButton called')
    console.log(@annotator)
    
    # add the reply button to the viewer element's controls element 
    element = @annotator.element.find('.annotator-annotation.annotator-item').find('.annotator-controls')
    reply_button = $('<button class="annotator-reply">Reply</button><div id="dialog">')
    element.append(reply_button)
    

  onReplyClick: ->
    console.log("You clicked on the reply button")
    
    # add a text entry area to the viewer
    viewer = @annotator.element.find('.annotator-annotation.annotator-item')
    viewer.append('''<label> Reply to this annotation </label> 
        <br/> 
        <textarea class="replyentry" rows="6" cols="40"> </textarea>
        <br/>
        <button class="annotator-reply-entry">Reply</button>">
        ''')

  onReplyEntryClick: ->
    # get content of the textarea
    textarea = @annotator.element.find('.replyentry')
    console.log(textarea.val())
    





    
    
     
