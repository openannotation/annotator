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
  # @element. See Delegator#addEvents() for details.
  events:
    'beforeAnnotationCreated': 'addFieldsToAnnotation'
    'annotationViewerShown':   'updateViewer'
    'annotationEditorShown':   'updateEditor'
    'annotationEditorHidden':  'clearEditor'
    'annotationEditorSubmit':  'updateAnnotationPermissions'

  # A Object literal of default options for the class.
  options:
    userId: (user) -> user
    userString: (user) -> user
    userAuthorize: (user, token) -> user == token
    user: null
    permissions: {
      read:    []
      update:  []
      destroy: []
      admin:   []
    }
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

  # Event callback: Appends the @user and @options.permissions objects to the
  # provided annotation object. Only appends the user if one has been set.
  #
  # event      - An Event object.
  # annotation - An annotation object.
  #
  # Examples
  #
  #   annotation = {text: 'My comment'}
  #   permissions.addFieldsToAnnotation(event, annotation)
  #   console.log(annotation)
  #   # => {text: 'My comment', user: 'Alice', permissions: {...}}
  #
  # Returns nothing.
  addFieldsToAnnotation: (event, annotation) =>
    if annotation
      annotation.permissions = @options.permissions

      if @user
        annotation.user = @options.userId(@user)

  # Public: Determines whether the provided action can be performed on the
  # annotation. It does this in several stages.
  #
  # 1. If the annotation has a permissions property with an array of tokens
  #    for the current action. If it does not have an array for the current
  #    action it will assume the action can ber performed.
  #    If an array of tokens are present it will pass them through to the
  #    @options.userAuthorize() callback and return the result.
  #
  # 2. If the annotation has a user property and @user is set it will pass the
  #    annotation.user into @options.userId() and see if it matches the current
  #    user (@user). If it does it will return true.
  #
  # 3. Finally if none of these criteria are met the method will assume the
  #    annotation is editable and return true.
  #
  # action     - String representing the action to be performed. Must be one of
  #              the following: read/update/destroy/admin. See @options.permissions
  #              for more details.
  # annotation - An Object literal annotation.
  #
  # Examples
  #
  #   permissions.setUser(null)
  #   permissions.authorize('update', {})
  #   # => true
  #
  #   permissions.setUser('alice')
  #   permissions.authorize('update', {user: 'alice'})
  #   # => true
  #   permissions.authorize('update', {user: 'bob'})
  #   # => false
  #
  #   permissions.setUser('alice')
  #   permissions.authorize('update', {
  #     user: 'bob',
  #     permissions: ['update': ['alice', 'bob']]
  #   })
  #   # => true
  #   permissions.authorize('destroy', {
  #     user: 'bob',
  #     permissions: [
  #       'update': ['alice', 'bob']
  #       'destroy': ['bob']
  #     ]
  #   })
  #   # => false
  #
  # Returns a Boolean, true if the action can be performed on the annotation.
  authorize: (action, annotation) ->
    # Fine-grained custom authorization
    if annotation.permissions
      tokens = annotation.permissions[action] || []

      if tokens.length == 0
        # Empty or missing tokens array so anyone can perform action.
        return true

      for token in tokens
        if @options.userAuthorize.call(@options, @user, token)
          return true

      # No tokens matched, action should not be perfomed.
      return false

    # Coarse-grained authorization
    else if annotation.user
      # If @user is set, and the annotation belongs to @user, allow.
      return @user and @options.userId(@user) == annotation.user

    # No authorization info on annotation: free-for-all!
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

        if this.authorize('update', annotations[i])
          $updateEl.show()
        else
          $updateEl.hide()

        if this.authorize('delete', annotations[i])
          $deleteEl.show()
        else
          $deleteEl.hide()

      else if "user" of annotations[i]

        if this.authorize(null, annotations[i])
          $controlEl.children().andSelf().show()
        else
          $controlEl.hide()

      else
        $controlEl.children().andSelf().show()
