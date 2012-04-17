class Annotator.Plugin.Comment extends Annotator.Plugin
  events:
    'annotationViewerShown' : 'addReplyButton'
    '.annotator-reply-save click': 'onReplyEntryClick'
    '.annotator-cancel click': 'hide'
    '.replyentry keydown' : 'processKeypress'
    '.replyentry click' : 'processKeypress'
    '.annotator-delete-reply click' : 'deleteReply'
  constructor: (element) ->
      super

    
  # Public: Initialises the plugin and adds custom fields to both the
  # annotator viewer and editor. The plugin also checks if the annotator is
  # supported by the current browser.
  #
  # Returns nothing.
  pluginInit: ->
    return unless Annotator.supported()
  
  # Add a reply button to the viewer widget's controls span
  addReplyButton: (viewer, annotations) ->
    # Annotations are displayed in the order they they were entered into the viewer

    annotator_listing = @annotator.element.find('.annotator-annotation.annotator-item')
    for l, i in annotator_listing
      l = $(l)
      
      replies = []
      # sort the annotations by creation time
      unsorted = @annotator.dumpAnnotations()
      sorted = unsorted.sort (a,b) ->
        return if a.created.toUpperCase() >= b.created.toUpperCase() then 1 else -1

      for ann in sorted.reverse()
        if ann.parent?
          if ann.parent == annotations[i].id
            replies.push ann.reply
      if replies.length > 0
        l.append('''<div style='padding:5px'> <span> Replies </span></div>
            <div id="Replies">
          
          <li class="Replies">
          </li></div>''')
      if replies.length > 0
        replylist = @annotator.element.find('.Replies')
        
        # write the replies into the correct places of the viewer. This algorithm handles overlapping annotations 
        for reply in replies.reverse()
          $(replylist[i]).append('''<div class='reply'>
            <span class='replyuser'>''' + reply.user + '''</span><button TITLE="Delete" class='annotator-delete-reply'>x</button><div class='replytext'>''' + reply.reply + '''</div></div>''')

      # Add the textarea
      l.append('''<div class='replybox'>
          <textarea class="replyentry" placeholder="Reply to this annotation..."></textarea>
          ''')

    viewer.checkOrientation()

 
    
  # Handle the event when the submit button is clicked
  #
  onReplyEntryClick: (event) ->
    # get content of the textarea
    item =  $(event.target).parent().parent()
    textarea = item.find('.replyentry')
    reply = textarea.val()
    if reply != '' 
      replyObject = @getReplyObject()
      #console.log( @annotator.plugins.Permissions)
      if @annotator.plugins.Permissions.user 
        replyObject.user = @annotator.plugins.Permissions.user.name
      else
        replyObject.user = "Anonymous"

      replyObject.reply = reply

      item = $(event.target).parents('.annotator-annotation')
      
      # make a new annotation object in which we can save the reply.
      new_annotation = @annotator.createAnnotation()

      new_annotation.ranges = []
      new_annotation.parent = item.data('annotation').id
      new_annotation.highlights = item.data('annotation').highlights      
      replyObject = @getReplyObject()
      replyObject.user = new_annotation.user
      replyObject.reply = reply
      new_annotation.reply = replyObject
      
      new_annotation = @annotator.setupAnnotation(new_annotation)
      console.log('setup complete', new_annotation)

      # hide the viewer
      @annotator.viewer.hide()
    

  deleteReply: (event) ->
    # delete the reply
    reply_item = $(event.target).parents('.reply')
    parent_id = reply_item.parents('.annotator-annotation').data('annotation').id
    reply_text = reply_item.find('.replytext')[0].innerHTML
    
    # now look for annotations with parent == parent_id AND reply that matches reply_text and delete them
    for ann in @annotator.dumpAnnotations()
      if ann.parent == parent_id
        if ann.reply.reply == reply_text
            #          console.log('match, ', ann)
          ann.highlights = []
          @annotator.deleteAnnotation(ann)
          # remove reply from DOM
          $(reply_item).replaceWith('')
          break


  getReplyObject: ->
    replyObject = 
        user: "anonymous"
        reply: ""
        
    replyObject
    
    
  processKeypress: (event) =>
    item =  $(event.target).parent()
    controls = item.find('.annotator-reply-controls')
    if controls.length == 0
      item.append('''<div class="annotator-reply-controls">
          <a href="#save" class="annotator-reply-save">Save</a>
          <a href="#cancel" class="annotator-cancel">Cancel</a>
          </div>
          </div>
          ''')
      @annotator.viewer.checkOrientation()

    if event.keyCode is 27 # "Escape" key => abort.
      @annotator.viewer.hide()
    else if event.keyCode is 13 and !event.shiftKey
      # If "return" was pressed without the shift key, we're done.
      @onReplyEntryClick(event)
 
  hide: ->
    @annotator.viewer.hide()
