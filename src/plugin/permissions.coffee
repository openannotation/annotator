# Public: Plugin for setting permissions on newly created annotations as well as
# managing user permissions such as viewing/editing/deleting annotions.
#
# element - A DOM Element upon which events are bound. When initialised by
#           the Annotator it is the Annotator#element.
# options - An Object literal containing custom options.
#
# Examples
#
#   new Annotator.plugin.Permissions(annotator.element, {
#     user: 'Alice'
#   })
#
# Returns a new instance of the Permissions Object.
class Annotator.Plugin.Permissions extends Annotator.Plugin

  # A Object literal consisting of event/method pairs to be bound to
  # Permissions#element.
  # See Delegator#addEvents() for details.
  events:
    'beforeAnnotationCreated': 'addUserToAnnotation'
    'annotationViewerShown':   'updateViewer'
    'annotationEditorShown':   'updateEditor'
    'annotationEditorHidden':  'clearEditor'
    'annotationEditorSubmit':  'updateAnnotationPermissions'

  # A Object literal of default options for the class.
  options:
    userId: (user) -> user
    userString: (user) -> user
    userGroups: (user) -> ['public']
    html:
      publiclyEditable: """
                        <input class='annotator-editor-user' type='checkbox' value='1' />
                        <label>Allow anyone to edit this annotation</label>
                        """

  # The constructor called when a new instance of the Permissions
  # plugin is created. See class documentation for usage.
  #
  # element - A DOM Element upon which events are bound..
  # options - An Object literal containing custom options.
  #
  # Returns an instance of the Permissions object.
  constructor: (element, options) ->
    super
    this.addEvents()

  # Public: Sets the Permissions#user property.
  #
  # user - A String or Object to represent the current user.
  #
  # Examples
  #
  #   permissions.setUser('Alice')
  #
  #   permissions.setUser({id: 35, name: 'Alice'})
  #
  # Returns nothing.
  setUser: (user) ->
    @user = user

  # Event callback: Appends the Permissions#user to the annotation object.
  # Only appends the user object if one has been set.
  #
  # event      - An Event object.
  # annotation - An annotation object.
  #
  # Examples
  #
  #   annotation = {text: 'My comment'}
  #   permissions.addUserToAnnotation(event, annotation)
  #   console.log(annotation)
  #   # => {text: 'My comment', user: 'Alice'}
  #
  # Returns
  addUserToAnnotation: (event, annotation) =>
    if @user and annotation
      annotation.user = @options.userId(@user)

  authorise: (action, annotation) ->
    # Fine-grained authorization
    if p = annotation.permissions

      # If the requested action isn't in permissions, it's allowed by default
      if not action or not p[action]
        true

      # The requested action is in permissions.
      else
        # If @user is in the permissions for this action, allow.
        if "user:#{@options.userId(@user)}" in p[action]
          true

        # User not allowed. Try groups:
        else if groups = @options.userGroups(@user)
          for g in groups
            if "group:#{g}" in p[action]
              return true

          false

    # Coarse-grained authorization
    else if u = annotation.user

      # If @user is set, and the annotation belongs to @user, allow.
      if @user and @options.userId(@user) == u
        true
      else
        false

    # No authorization info on annotation: free-for-all!
    else
      true

  # Event callback: Appends a checkbox to the Annotator editor so the user can
  # edit the annotation's permissions.
  #
  # event         - An Event instance.
  # editorElement - A DOM Element representing the annotation editor.
  # annotation    - An annotation Object.
  #
  # Returns nothing.
  updateEditor: (e, editorElement, annotation) =>
    unless @globallyEditableCheckbox
      # Unique ID for for and id attributes of checkbox.
      uid = +(new Date)

      editorControls = editorElement.find('.annotator-editor-controls')
      @globallyEditableCheckbox = $(@options.html.publiclyEditable)
        .insertBefore(editorControls)
        .filter('label')
          .attr('for', uid).end()
        .filter('input')
          .attr('id', uid)

    if annotation?.permissions
      this.clearEditor(e, editorElement)
    else
      @globallyEditableCheckbox.attr('checked', 'checked')

  # Event callback: Resets the editor to a default state.
  #
  # event         - An Event instance.
  # editorElement - A DOM Element representing the annotation editor.
  #
  # Returns nothing.
  clearEditor: (event, editorElement) =>
    if @globallyEditableCheckbox
      @globallyEditableCheckbox.removeAttr('checked')

  # Event callback: updates the annotation.permissions object based on the state
  # of Permissions#globallyEditableCheckbox. If it is checked then permissions
  # are set to world writable otherwise they use the original settings.
  #
  # event         - An Event instance.
  # editorElement - A DOM Element representing the annotation editor.
  # annotation    - An annotation Object.
  #
  # Returns nothing.
  updateAnnotationPermissions: (event, editorElement, annotation) =>
    if @globallyEditableCheckbox.is(':checked')
      # Cache the permissions in case the user unchecks global permissions later.
      $.data(annotation, 'permissions', annotation.permissions)
      delete annotation.permissions
    else
      # Retrieve and re-apply the permissions.
      permissions = $.data(annotation, 'permissions')
      annotation.permissions = permissions if permissions

  # Event callback: updates the annotation viewer to inlude the display name
  # for the user obtained through Permissions#options.userString().
  #
  # event         - An Event instance.
  # viewerElement - A DOM Element representing the annotation viewer.
  # annotations   - An Array of annotations to display.
  #
  # Returns nothing.
  updateViewer: (event, viewerElement, annotations) =>
    annElements = $(viewerElement).find('.annotator-ann')

    for i in [0...annElements.length]
      $controlEl = annElements.eq(i).find('.annotator-ann-controls')
      $textEl    = annElements.eq(i).find('.annotator-ann-text')

      if u = annotations[i].user
        $("<div class='annotator-ann-user'>#{@options.userString(u)}</div>").insertAfter($textEl)

      if "permissions" of annotations[i]
        $controlEl.show()
        $updateEl = $controlEl.find('.edit')
        $deleteEl = $controlEl.find('.delete')

        if this.authorise('update', annotations[i])
          $updateEl.show()
        else
          $updateEl.hide()

        if this.authorise('delete', annotations[i])
          $deleteEl.show()
        else
          $deleteEl.hide()

      else if "user" of annotations[i]

        if this.authorise(null, annotations[i])
          $controlEl.children().andSelf().show()
        else
          $controlEl.hide()

      else
        $controlEl.children().andSelf().show()
