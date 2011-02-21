describe 'Annotator.Plugin.User', ->
  el = null
  u = null

  beforeEach ->
    el = $("<div class='annotator-viewer'></div>")[0]
    u = new Annotator.Plugin.User(el)

  it "it should add the userId of the current user to newly created annotations on beforeAnnotationCreated", ->
    ann = {}
    $(el).trigger('beforeAnnotationCreated', [ann])
    expect(ann).toEqual({})

    ann = {}
    u.setUser('alice')
    $(el).trigger('beforeAnnotationCreated', [ann])
    expect(ann.user).toEqual('alice')

    ann = {}
    u.setUser({id: 'alice'})
    u.options.userId = (user) -> user.id
    $(el).trigger('beforeAnnotationCreated', [ann])
    expect(ann.user).toEqual('alice')

  describe 'authorise', ->
    annotations = [
      {}                  # Everything should be allowed

      { user: 'alice' }   # Only alice should be allowed to edit/delete.

      { permissions: {} } # Everything should be allowed.

      { permissions: {    # No-one can update. Anyone can delete.
        'update': []
      } }

      { permissions: {    # Anyone can update, assuming default @options.userGroups.
        'update': ['group:public']
      } }

      { permissions: {    # Only alice can update.
        'update': ['user:alice']
      } }

      { permissions: {    # alice and bob can both update.
        'update': ['user:alice', 'user:bob']
      } }

      { permissions: {    # alice and bob can both update. Anyone for whom
                          # @options.userGroups(user) includes 'admin' can
                          # also update.
        'update': ['user:alice', 'user:bob', 'group:admin']
      } }
    ]

    it 'should allow any action for an annotation with no authorisation info', ->
      a = annotations[0]
      expect(u.authorise(null,  a)).toBeTruthy()
      expect(u.authorise('foo', a)).toBeTruthy()
      u.setUser('alice')
      expect(u.authorise(null,  a)).toBeTruthy()
      expect(u.authorise('foo', a)).toBeTruthy()

    it 'should NOT allow any action if annotation.user and no @user is set', ->
      a = annotations[1]
      expect(u.authorise(null,  a)).toBeFalsy()
      expect(u.authorise('foo', a)).toBeFalsy()

    it 'should allow any action if @options.userId(@user) == annotation.user', ->
      a = annotations[1]
      u.setUser('alice')
      expect(u.authorise(null,  a)).toBeTruthy()
      expect(u.authorise('foo', a)).toBeTruthy()

    it 'should NOT allow any action if @options.userId(@user) != annotation.user', ->
      a = annotations[1]
      u.setUser('bob')
      expect(u.authorise(null,  a)).toBeFalsy()
      expect(u.authorise('foo', a)).toBeFalsy()

    it 'should allow any action if annotation.permissions == {}', ->
      a = annotations[2]
      expect(u.authorise(null,  a)).toBeTruthy()
      expect(u.authorise('foo', a)).toBeTruthy()
      u.setUser('alice')
      expect(u.authorise(null,  a)).toBeTruthy()
      expect(u.authorise('foo', a)).toBeTruthy()

    it 'should NOT allow an action if annotation.permissions[action] == []', ->
      a = annotations[3]
      expect(u.authorise('update', a)).toBeFalsy()
      u.setUser('bob')
      expect(u.authorise('update', a)).toBeFalsy()

    it 'should (by default) allow an action if annotation.permissions[action] includes "group:public"', ->
      a = annotations[4]
      expect(u.authorise('update', a)).toBeTruthy()
      u.setUser('bob')
      expect(u.authorise('update', a)).toBeTruthy()

    it 'should (by default) allow an action if annotation.permissions[action] includes "user:@user"', ->
      a = annotations[5]
      expect(u.authorise('update', a)).toBeFalsy()
      u.setUser('bob')
      expect(u.authorise('update', a)).toBeFalsy()
      u.setUser('alice')
      expect(u.authorise('update', a)).toBeTruthy()

      a = annotations[6]
      u.setUser(null)
      expect(u.authorise('update', a)).toBeFalsy()
      u.setUser('bob')
      expect(u.authorise('update', a)).toBeTruthy()
      u.setUser('alice')
      expect(u.authorise('update', a)).toBeTruthy()

    it 'should allow an action if annotation.permissions[action] includes "user:@options.userId(@user)"', ->
      a = annotations[5]
      u.options.userId = (user) -> user?.id or null

      expect(u.authorise('update', a)).toBeFalsy()
      u.setUser({id: 'alice'})
      expect(u.authorise('update', a)).toBeTruthy()

    it 'should allow an action if annotation.permissions[action] includes "user:@options.userId(@user)"', ->
      a = annotations[7]
      u.options.userGroups = (user) -> user?.groups

      expect(u.authorise('update', a)).toBeFalsy()
      u.setUser({id: 'foo', groups: ['other']})
      expect(u.authorise('update', a)).toBeFalsy()
      u.setUser({id: 'charlie', groups: ['admin']})
      expect(u.authorise('update', a)).toBeTruthy()

  describe 'editor update', ->
    checkboxEl  = null
    annotations = [
      {},
      {},
      {permissions: {'update': ['user:Alice']}}
    ]

    beforeEach ->
      editorEl = $("<div><div class='annotator-editor-controls'></div></div>")
      $(el).trigger('annotationEditorShown', [editorEl, annotations.shift()])
      checkboxEl = editorEl.find('.annotator-editor-user')

    it "should display 'Allow anyone to edit…' checkbox in the element", ->
      expect(checkboxEl.length).toBe(1)

    it "should have a checked checkbox when there are no permissions", ->
      expect(checkboxEl.is(':checked')).toBeTruthy()

    it "should have an unchecked checkbox when there are permissions", ->
      expect(checkboxEl.is(':checked')).toBeFalsy()

  describe 'editor submit', ->
    editorEl = null
    annotation = null

    beforeEach ->
      editorEl   = $("<div><div class='annotator-editor-controls'></div></div>")
      annotation = {permissions: {'update': ['user:Alice']}}
      $(el).trigger('annotationEditorShown', [editorEl, annotation])

    it "should leave permissions when 'Anyone can edit' checkbox is unchecked", ->
      u.globallyEditableCheckbox.removeAttr('checked')
      $(el).trigger('annotationEditorSubmit', [editorEl, annotation])
      expect(annotation.permissions).toBeTruthy()

    it "should remove permissions when 'Anyone can edit' checkbox is checked", ->
      u.globallyEditableCheckbox.attr('checked', 'checked')
      $(el).trigger('annotationEditorSubmit', [editorEl, annotation])
      expect(annotation.permissions).toBeFalsy()

    it "should restore permissions when 'Anyone can edit' checkbox is unchecked for a second time", ->
      u.globallyEditableCheckbox.attr('checked', 'checked')
      $(el).trigger('annotationEditorSubmit', [editorEl, annotation])
      expect(annotation.permissions).toBeFalsy()

      u.globallyEditableCheckbox.removeAttr('checked')
      $(el).trigger('annotationEditorSubmit', [editorEl, annotation])
      expect(annotation.permissions).toBeTruthy()

  describe 'viewer update', ->
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

      expect(controlEls.eq(0).css('display')).not.toEqual('none')
      expect(controlEls.eq(1).css('display')).toEqual('none')

    it "should show controls for annotations without a user", ->
      controlEls = $(el).find('.annotator-ann-controls')
      expect(controlEls.eq(2).css('display')).not.toEqual('none')

  describe 'fine-grained use (user and permissions)', ->
    annotations = null

    beforeEach ->
      annotations = [
        {
          user: 'alice'
          permissions: {
            'update': ['group:public']
            'delete': ['user:alice']
          }
        },
        {
          user: 'bob'
          permissions: {
            'update': ['user:bob'],
            'delete': ['user:bob']
          }
        }
      ]

      viewerEls = []
      annElSrc = """
                 <div class='annotator-ann'>
                   <div class='annotator-ann-controls'><span class='edit'></span><span class='delete'></span> </div>
                   <div class='annotator-ann-text'></div>
                 </div>
                 """

      for i in [0...annotations.length]
        viewerEls.push($(annElSrc).appendTo(el))


    it "it should should allow editing if @user is authorised for the 'update' action", ->
      u.setUser('bob')
      $(el).trigger('annotationViewerShown', [el, annotations])
      editEls = $(el).find('.annotator-ann-controls .edit')

      expect($(el).find('.annotator-ann-controls').css('display')).not.toEqual('none')
      expect(editEls.eq(0).css('display')).not.toEqual('none')
      expect(editEls.eq(1).css('display')).not.toEqual('none')

    it "it should should allow deleting if @user is authorised for the 'delete' action", ->
      u.setUser('bob')
      $(el).trigger('annotationViewerShown', [el, annotations])

      deleteEls = $(el).find('.annotator-ann-controls .delete')

      expect(deleteEls.eq(0).css('display')).toEqual('none')
      expect(deleteEls.eq(1).css('display')).not.toEqual('none')
