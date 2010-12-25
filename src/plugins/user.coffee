$ = jQuery

class Annotator.Plugins.User extends Delegator
  events:
    'annotationViewerShown': 'updateViewerWithUsers'

  options:
    # Define how to display the 'user' property of the annotation. By
    # default assumes the value is string-coerceable, so just returns the
    # value. If the user property were an object in and of itself, this
    # could, for example, return u.name, or u.getName(), etc.
    #
    # @param elem The element representing the annotation.
    # @param user The value of the relevant annotation's "user" property.
    display: (elem, user) ->
      $(elem).append("<span class='user'>&ndash; #{user}</span>")

  constructor: (element, options) ->
    super()
    this.addEvents()

  updateViewerWithUsers: (e, viewerElement, annotations) ->
    paras = $(viewerElement).find('p')

    for p in paras
      user = $(p).data('annotation').user
      if (user)
        @options.display(p, user)