describe 'Annotator.Plugin.AnnotateItPermissions', ->
  el = null
  permissions = null

  beforeEach ->
    el = $("<div class='annotator-viewer'></div>").appendTo('body')[0]
    permissions = new Annotator.Plugin.AnnotateItPermissions(el)

  afterEach -> $(el).remove()

  describe 'authorize', ->
    annotations = null

    beforeEach ->
      annotations = [
        {}                                        # 0
        { user: 'alice' }                         # 1
        { user: 'alice', consumer: 'annotateit' } # 2
        { permissions: {} }                       # 3
        {                                         # 4
          permissions: {
            'read': ['group:__world__']
          }
        }
        {                                         # 5
          permissions: {
          'update': ['group:__authenticated__']
          }
        }
        {                                         # 6
          consumer: 'annotateit'
          permissions: {
            'read': ['group:__consumer__']
          }
        }
      ]

    it 'should NOT allow any action for an annotation with no owner info and no permissions', ->
      a = annotations[0]
      expect(permissions.authorize(null,  a)).toBeFalsy()
      expect(permissions.authorize('foo', a)).toBeFalsy()
      permissions.setUser('alice')
      permissions.setConsumer('annotateit')
      expect(permissions.authorize(null,  a)).toBeFalsy()
      expect(permissions.authorize('foo', a)).toBeFalsy()

    it 'should NOT allow any action if an annotation has only user set (but no consumer)', ->
      a = annotations[1]
      expect(permissions.authorize(null,  a)).toBeFalsy()
      expect(permissions.authorize('foo', a)).toBeFalsy()
      permissions.setUser('alice')
      permissions.setConsumer('annotateit')
      expect(permissions.authorize(null,  a)).toBeFalsy()
      expect(permissions.authorize('foo', a)).toBeFalsy()

    it 'should allow any action if the current auth info identifies the owner of the annotation', ->
      a = annotations[2]
      permissions.setUser('alice')
      permissions.setConsumer('annotateit')
      expect(permissions.authorize(null,  a)).toBeTruthy()
      expect(permissions.authorize('foo', a)).toBeTruthy()

    it 'should NOT allow any action for an annotation with no owner info and empty permissions field', ->
      a = annotations[3]
      expect(permissions.authorize(null,  a)).toBeFalsy()
      expect(permissions.authorize('foo', a)).toBeFalsy()
      permissions.setUser('alice')
      permissions.setConsumer('annotateit')
      expect(permissions.authorize(null,  a)).toBeFalsy()
      expect(permissions.authorize('foo', a)).toBeFalsy()

    it 'should allow an action when the action field contains the world group', ->
      a = annotations[4]
      expect(permissions.authorize('read', a)).toBeTruthy()
      permissions.setUser('alice')
      permissions.setConsumer('annotateit')
      expect(permissions.authorize('read', a)).toBeTruthy()

    it 'should allow an action when the action field contains the authenticated group and the plugin has auth info', ->
      a = annotations[5]
      expect(permissions.authorize('update', a)).toBeFalsy()
      permissions.setUser('anyone')
      permissions.setConsumer('anywhere')
      expect(permissions.authorize('update', a)).toBeTruthy()

    it 'should allow an action when the action field contains the consumer group and the plugin has auth info with a matching consumer', ->
      a = annotations[6]
      expect(permissions.authorize('read', a)).toBeFalsy()
      permissions.setUser('anyone')
      permissions.setConsumer('anywhere')
      expect(permissions.authorize('read', a)).toBeFalsy()
      permissions.setConsumer('annotateit')
      expect(permissions.authorize('read', a)).toBeTruthy()

    it 'should allow an action when the action field contains the consumer group and the plugin has auth info with a matching consumer', ->
      a = annotations[6]
      expect(permissions.authorize('read', a)).toBeFalsy()
      permissions.setUser('anyone')
      permissions.setConsumer('anywhere')
      expect(permissions.authorize('read', a)).toBeFalsy()
      permissions.setConsumer('annotateit')
      expect(permissions.authorize('read', a)).toBeTruthy()
