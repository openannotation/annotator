# Public: Plugin for managing user permissions under the rather more specialised
# permissions model used by [AnnotateIt](http://annotateit.org).
#
# element - A DOM Element upon which events are bound. When initialised by
#           the Annotator it is the Annotator element.
# options - An Object literal containing custom options.
#
# Examples
#
#   new Annotator.plugin.AnnotateItPermissions(annotator.element, {
#     user: 'Alice',
#     consumer: 'annotateit'
#   })
#
# Returns a new instance of the AnnotateItPermissions Object.
class Annotator.Plugin.AnnotateItPermissions extends Annotator.Plugin.Permissions

  # A Object literal of default options for the class.
  options:

    # Displays an "Anyone can view this annotation" checkbox in the Editor.
    showViewPermissionsCheckbox: true

    # Displays an "Anyone can edit this annotation" checkbox in the Editor.
    showEditPermissionsCheckbox: true

    # Abstract user groups used by userAuthorize function
    groups:
      world: 'group:__world__'
      authenticated: 'group:__authenticated__'
      consumer: 'group:__consumer__'

    # [This subclass of Permissions doesn't provide a userId function, as it is
    #  assumed that the user field of each annotation is a straightforward string
    #  userId.]

    # Public: Used by the plugin to determine a display name for the @user
    # property. By default this accepts and returns the user String but can be
    # over-ridden in the @options object passed into the constructor.
    #
    # user - A String username or null if no user is set.
    #
    # Returns the String provided as user object
    userString: (user) -> user

    # Public: Used by AnnotateItPermissions#authorize to determine whether a user can
    # perform an action on an annotation.
    #
    # This should do more-or-less the same thing as the server-side authorization
    # code, which is to be found at
    #   https://github.com/okfn/annotator-store/blob/master/annotator/authz.py
    #
    # Returns a Boolean, true if the user is authorised for the action provided.
    userAuthorize: (action, annotation, user, consumer) ->
      permissions = annotation.permissions or {}
      action_field = permissions[action] or []

      if not (user and consumer)
        return @groups.world in action_field

      else
        if @groups.world in action_field
          return true
        else if user == annotation.user and consumer == annotation.consumer
          return true
        else if @groups.authenticated in action_field
          return true
        else if consumer == annotation.consumer and @groups.consumer in action_field
          return true
        else if consumer == annotation.consumer and user in action_field
          return true
        else
          return false

    # Default user object.
    user: ''

    # Default consumer
    consumer: 'annotateit'

    # Default permissions for all annotations. Anyone can
    # read, but only annotation owners can update/delete/admin.
    permissions: {
      'read':   ['group:__world__']
      'update': []
      'delete': []
      'admin':  []
    }

  # The constructor called when a new instance of the AnnotateItPermissions
  # plugin is created. See class documentation for usage.
  #
  # element - A DOM Element on which events are bound.
  # options - An Object literal containing custom options.
  #
  # Returns an instance of the Permissions object.
  constructor: (element, options) ->
    super

    if @options.consumer
      this.setConsumer(@options.consumer)
      delete @options.consumer

  # Public: Sets the AnnotateItPermissions#consumer property.
  #
  # consumer - A String representing the consumer of the current user.
  #
  # Examples
  #
  #   permissions.setConsumer('annotateit')
  #
  # Returns nothing.
  setConsumer: (consumer) ->
    @consumer = consumer

  # Public: Determines whether the provided action can be performed on the
  # annotation. This uses the user-configurable 'userAuthorize' method to
  # determine if an annotation is annotatable. See the default method for
  # documentation on its behaviour.
  #
  # Returns a Boolean, true if the action can be performed on the annotation.
  authorize: (action, annotation, user, consumer) ->
    user = @user if user == undefined
    consumer = @consumer if consumer == undefined

    if @options.userAuthorize
      return @options.userAuthorize.call(@options, action, annotation, user, consumer)

    else # userAuthorize nulled out: free-for-all!
      return true

  # Event callback: Appends the @options.permissions, @options.user and
  # @options.consumer objects to the provided annotation object.
  #
  # annotation - An annotation object.
  #
  # Examples
  #
  #   annotation = {text: 'My comment'}
  #   permissions.addFieldsToAnnotation(annotation)
  #   console.log(annotation)
  #   # => {text: 'My comment', user: 'alice', consumer: 'annotateit', permissions: {...}}
  #
  # Returns nothing.
  addFieldsToAnnotation: (annotation) =>
    super
    if annotation and @consumer
      annotation.consumer = @consumer

  # Field callback: Updates the state of the "anyone can…" checkboxes
  #
  # action     - The action String, either "view" or "update"
  # field      - A DOM Element containing a form input.
  # annotation - An annotation Object.
  #
  # Returns nothing.
  updatePermissionsField: (action, field, annotation) =>
    field = $(field).show()
    input = field.find('input').removeAttr('disabled')

    # Do not show field if current user is not admin.
    field.hide() unless this.authorize('admin', annotation)

    # See if we can authorise with any old user from this consumer
    if this.authorize(action, annotation || {}, '__nonexistentuser__')
      input.attr('checked', 'checked')
    else
      input.removeAttr('checked')

  # Field callback: updates the annotation.permissions object based on the state
  # of the field checkbox. If it is checked then permissions are set to world
  # writable otherwise they use the original settings.
  #
  # action     - The action String, either "view" or "update"
  # field      - A DOM Element representing the annotation editor.
  # annotation - An annotation Object.
  #
  # Returns nothing.
  updateAnnotationPermissions: (type, field, annotation) =>
    annotation.permissions = @options.permissions unless annotation.permissions

    dataKey = type + '-permissions'

    if $(field).find('input').is(':checked')
      annotation.permissions[type] = [if type == 'read' then @options.groups.world else @options.groups.consumer]
    else
      annotation.permissions[type] = []

  # Sets the Permissions#user and Permissions#consumer properties on the basis
  # of a received authToken.
  #
  # token - the authToken received by the Auth plugin
  #
  # Returns nothing.
  _setAuthFromToken: (token) =>
    super
    this.setConsumer(token.consumerKey)
