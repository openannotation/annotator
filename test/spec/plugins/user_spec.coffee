describe 'Annotator.Plugin.User', ->
  el = null
  u = null

  beforeEach ->
    el = $("<div class='annotator-viewer'></div>")[0]
    u = new Annotator.Plugins.User(el)

  it "it should add the current user to newly created annotations on beforeAnnotationCreated", ->
    ann = {}
    $(el).trigger('beforeAnnotationCreated', [ann])
    expect(ann).toEqual({})

    u.setUser('alice')
    $(el).trigger('beforeAnnotationCreated', [ann])
    expect(ann).toEqual({user: 'alice'})

  describe 'viewer changes', ->

    beforeEach ->
      u.setUser('alice')
      annotations = [{user: 'alice'}, {user: 'bob'}, {}]

      viewerEls = []
      annElSrc = """
                 <div class='annotator-ann'>
                   <div class='annotator-ann-controls'></div>
                   <div class='annotator-ann-text'></div>
                 </div>
                 """

      for i in [0...annotations.length]
        viewerEls.push($(annElSrc).appendTo(el))

      $(el).trigger('annotationViewerShown', [el, annotations])

    it "it should display annotations' users in the viewer element", ->
      userEls = $(el).find('.annotator-ann-user')

      expect(userEls.length).toBe(2)
      expect(userEls.eq(0).text()).toEqual('alice')
      expect(userEls.eq(1).text()).toEqual('bob')

    it "should hide controls for users other than the current user", ->
      controlEls = $(el).find('.annotator-ann-controls')

      expect(controlEls.eq(0)).toBeVisible()
      expect(controlEls.eq(1)).toBeHidden()

    it "should show controls for annotations without a user", ->
      controlEls = $(el).find('.annotator-ann-controls')

      expect(controlEls.eq(2)).toBeVisible()

