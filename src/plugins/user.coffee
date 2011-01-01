$ = jQuery

class Annotator.Plugins.User extends Delegator
  events:
    'beforeAnnotationCreated': 'addUserToAnnotation'
    'annotationViewerShown': 'updateViewer'

  constructor: (element, options) ->
    super
    this.addEvents()

  setUser: (userid) ->
    @user = userid

  addUserToAnnotation: (e, annotation) =>
    if @user and annotation
      annotation.user = @user

  updateViewer: (e, viewerElement, annotations) =>
    annElements = $(viewerElement).find('.annotator-ann')

    for i in [0...annElements.length]
      user       = annotations[i].user
      $controlEl = annElements.eq(i).find('.annotator-ann-controls')
      $textEl    = annElements.eq(i).find('.annotator-ann-text')

      if user
        $("<div class='annotator-ann-user'>#{user}</div>").insertAfter($textEl)

        if not @user or (@user != user)
          $controlEl.hide()
        else
          $controlEl.show()

      else
          $controlEl.show()
