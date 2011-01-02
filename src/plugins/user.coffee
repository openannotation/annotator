$ = jQuery

class Annotator.Plugins.User extends Delegator
  events:
    'beforeAnnotationCreated': 'addUserToAnnotation'
    'annotationViewerShown': 'updateViewer'

  options:
    userId: (user) -> user
    userString: (user) -> user
    userGroups: (user) -> ['public']

  constructor: (element, options) ->
    super
    this.addEvents()

  setUser: (userid) ->
    @user = userid

  addUserToAnnotation: (e, annotation) =>
    if @user and annotation
      annotation.user = @user

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

  updateViewer: (e, viewerElement, annotations) =>
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
