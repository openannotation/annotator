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

    # Public: Used by the plugin to determine a unique id for the @user property.
    # By default this accepts and returns the user String but can be over-
    # ridden in the @options object passed into the constructor.
    #
    # user - A String username.
    #
    # Returns the String provided as user object.
    userId: (user) -> user

    # Public: Used by the plugin to determine a display name for the @user
    # property. By default this accepts and returns the user String but can be
    # over-ridden in the @options object passed into the constructor.
    #
    # user - A String username.
    #
    # Returns the String provided as user object
    userString: (user) -> user

    # Public: Used by Permissions#authorize to determine whether a user can
    # perform an action on an annotation. Overriding this function allows
    # a far more complex permissions sysyem.
    #
    # By default this compares the passed user to the token but can be
    # over-ridden in the @options object passed into the constructor.
    #
    # user  - An annotation user object, usually a String.
    # token - A String permissions token. These are set in the @options.permissions
    #         Object. e.g. permissions = {read: [], update: ['Alice']}. Here the
    #         one token for the update permisson is 'Alice' and this can be
    #         compare to the user parameter to see if they match.
    #
    # Examples:
    #
    #   # Default settings.
    #   plugin.setUser('Alice')
    #   annotation = {user: 'Bob', permissions: {'update': ['Alice', 'Bob']}}
    #   plugin.authorize('update', annotation)
    #   # => true ('Alice' is in the array of tokens for the update action)
    #
    #   # Contrived example of a custom JavaScript function that allows a
    #   # "group:Admin" token as well as an id for validation.
    #   plugin.options.userAuthorize = function (user, token) {
    #     if (user.group === 'Admin' && token === 'group:Admin') {
    #       return true;
    #     }
    #     else if (user.id === token) {
    #       return true;
    #     }
    #     return false;
    #   }
    #   plugin.setUser({id: 'Alice', group: 'Admin'})
    #   annotation = {user: 'Bob', permissions: {'update': ['Bob', 'group:Admin']}}
    #   # => true (User has the "admin" value set to thier group property)
    #
    # Returns a Boolean, true if the user is authorised for the token provided.
    userAuthorize: (user, token) -> user == token

    # Default user object.
    user: ''

    # Default permissions for all annotations. Anyone can perform any action.
    permissions: {
      read:    []
      update:  []
      destroy: []
      admin:   []
    }

    # Default HTML for the plugin elements.
    html:
      publiclyEditable: \
      """
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
  # user       - User Object to authorise. (default: @user)
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
  authorize: (action, annotation, user) ->
    user = @user if user == undefined

    # Fine-grained custom authorization
    if annotation.permissions
      tokens = annotation.permissions[action] || []

      if tokens.length == 0
        # Empty or missing tokens array so anyone can perform action.
        return true

      for token in tokens
        if @options.userAuthorize.call(@options, user, token)
          return true

      # No tokens matched, action should not be perfomed.
      return false

    # Coarse-grained authorization
    else if annotation.user
      # If @user is set, and the annotation belongs to @user, allow.
      return user and @options.userId(user) == annotation.user

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

    # See if we can authorise without a user.
    if this.authorize('update', annotation || {}, null)
      @globallyEditableCheckbox.attr('checked', 'checked')
    else
      this.clearEditor(e, editorElement)

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
    annotation.permissions = @options.permissions unless annotation.permissions

    if @globallyEditableCheckbox.is(':checked')
      # Cache the permissions in case the user unchecks global permissions later.
      $.data(annotation, 'permissions', annotation.permissions.update)
      annotation.permissions.update = []
    else
      # Retrieve and re-apply the permissions.
      permissions = $.data(annotation, 'permissions')
      annotation.permissions.update = permissions if permissions
      annotation.permissions.update.push(@options.userId(@user))

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
