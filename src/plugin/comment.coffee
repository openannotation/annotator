class Annotator.Plugin.Comment extends Annotator.Plugin
  events:
    'annotationViewerShown' : 'addReplyButton'
    '.annotator-reply click': 'onReplyClick'
    '.annotator-reply-entry click': 'onReplyEntryClick'
    '.numberOfReplies click'    :   'showReplies'
    '.replyentry keydown' : 'processKeypress'

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

  # Add a reply button to the viewer widget's controls span
  addReplyButton: (viewer, annotations) ->
    console.log('addReplyButton called')
    console.log(@annotator)
    
    # add the reply button to the viewer element's controls element 
    element = @annotator.element.find('.annotator-annotation.annotator-item').find('.annotator-controls')
    reply_button = $('<span class="annotator-reply">Reply</span>')
    element.append(reply_button)
    
    # Add a label that shows the number of replies
    console.log(viewer.annotations[0].replies?)
    if viewer.annotations[0].replies?
      numreplies = viewer.annotations[0].replies.length
      console.log('Number of replies, ', numreplies)
      viewer.element.find('.annotator-annotation.annotator-item').append('''
      <div class="numberOfReplies">
          <a class="repliesView">View '''+ numreplies + ''' replies</a>
      </div>''')
      
    
  #
  # Add a textarea to the viewer widget if the reply button is clicked
  #
  onReplyClick: (event) ->
    console.log("You clicked on the reply button")
    item = $(event.target).parents('.annotator-annotation')
    console.log(item)
 
    # add a text entry area to the viewer
    viewer = @annotator.element.find('.annotator-annotation.annotator-item')
    textarea = item.find('.replyentry')
    # add the textarea to the annotation which contains the reply button that was clicked.
    # item contains only the elements of that part of the viewer, instead of all current visible viewers
    # like when annotations overlap.
    if textarea.length == 0
      item.append('''<div class='replybox'><label> Reply to this annotation </label> 
          <br/> 
          <textarea class="replyentry" rows="6" cols="40"> </textarea>
          <br/>
          <div class="annotator-controls">
          <a href="#save" class="annotator-reply-entry">Reply</a>
          </div>
          </div>
          ''')


  # Handle the event when the submit button is clicked
  #
  onReplyEntryClick: (event) ->
    # get content of the textarea
    textarea = @annotator.element.find('.replyentry')
    reply = textarea.val()
    
    replyObject = @getReplyObject()
    
    if @annotator.plugins.Permissions.user 
      replyObject.user = @annotator.plugins.Permissions.user
    else
      replyObject.user = "Anonymous"

    replyObject.reply = reply

    #TODO DEBUG info
#    console.log(reply)
    item = $(event.target).parents('.annotator-annotation')
    
    #TODO DEBUG
    #console.log('item-data', item.data('annotation'))
    annotation = item.data('annotation')  
    if not annotation.replies?
      annotation.replies = []

    #TODO DEBUG
#    if @annotator.plugins.Permissions?
        #console.log('New reply by: ', @annotator.plugins.Permissions.user)
    annotation.replies.push replyObject
 #   else
        #console.log('New reply by: Anonymous')

    # publish annotationUpdated event so that the store can save the changes
    this.publish('annotationUpdated', [annotation])
    
    # hide the viewer
    @annotator.viewer.hide()
    
  showReplies: (event) ->
    # here we show the replies attached to the annotation
    viewer = @annotator.element.find('.annotator-annotation.annotator-item')
    replylist = viewer.find('.Replies')
    # get the annotation
    item = $(event.target).parents('.annotator-annotation')
    annotation = item.data('annotation')


    if replylist.length == 0
      viewer.append('''<div id="Replies">
        <li class="Replies">
        </li></div>''')
    replylist = viewer.find('.Replies')
    console.log(replylist.children())

    if replylist.children().length == 0
      # add all the replies into the div
      for reply in annotation.replies
        replylist.append('''<div class='reply'>
            <span class='replyuser'>''' + reply.user + '''</span>
            <div class='replytext'>''' + reply.reply + '''</div></div>''')

    console.log(replylist)




  getReplyObject: ->
    replyObject = 
        user: "anonymous"
        reply: ""
        
    replyObject
    
    
  processKeypress: (event) =>
    if event.keyCode is 27 # "Escape" key => abort.
      @annotator.viewer.hide()
    else if event.keyCode is 13 and !event.shiftKey
      # If "return" was pressed without the shift key, we're done.
      @onReplyEntryClick(event)
  
