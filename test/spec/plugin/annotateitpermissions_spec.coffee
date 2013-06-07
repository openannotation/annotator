describe 'Annotator.Plugin.AnnotateItPermissions', ->
  el = null
  permissions = null

  beforeEach ->
    el = $("<div class='annotator-viewer'></div>").appendTo('body')[0]
    permissions = new Annotator.Plugin.AnnotateItPermissions(el)

  afterEach -> $(el).remove()

  it "it should set user for newly created annotations on beforeAnnotationCreated", ->
    ann = {}
    permissions.setUser({userId: 'alice', consumerKey: 'fookey'})
    $(el).trigger('beforeAnnotationCreated', [ann])
    assert.equal(ann.user, 'alice')

  it "it should set consumer for newly created annotations on beforeAnnotationCreated", ->
    ann = {}
    permissions.setUser({userId: 'alice', consumerKey: 'fookey'})
    $(el).trigger('beforeAnnotationCreated', [ann])
    assert.equal(ann.consumer, 'fookey')

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
      assert.isFalse(permissions.authorize(null,  a))
      assert.isFalse(permissions.authorize('foo', a))
      permissions.setUser({userId: 'alice', consumerKey: 'annotateit'})
      assert.isFalse(permissions.authorize(null,  a))
      assert.isFalse(permissions.authorize('foo', a))

    it 'should NOT allow any action if an annotation has only user set (but no consumer)', ->
      a = annotations[1]
      assert.isFalse(permissions.authorize(null,  a))
      assert.isFalse(permissions.authorize('foo', a))
      permissions.setUser({userId: 'alice', consumerKey: 'annotateit'})
      assert.isFalse(permissions.authorize(null,  a))
      assert.isFalse(permissions.authorize('foo', a))

    it 'should allow any action if the current auth info identifies the owner of the annotation', ->
      a = annotations[2]
      permissions.setUser({userId: 'alice', consumerKey: 'annotateit'})
      assert.isTrue(permissions.authorize(null,  a))
      assert.isTrue(permissions.authorize('foo', a))

    it 'should NOT allow any action for an annotation with no owner info and empty permissions field', ->
      a = annotations[3]
      assert.isFalse(permissions.authorize(null,  a))
      assert.isFalse(permissions.authorize('foo', a))
      permissions.setUser({userId: 'alice', consumerKey: 'annotateit'})
      assert.isFalse(permissions.authorize(null,  a))
      assert.isFalse(permissions.authorize('foo', a))

    it 'should allow an action when the action field contains the world group', ->
      a = annotations[4]
      assert.isTrue(permissions.authorize('read', a))
      permissions.setUser({userId: 'alice', consumerKey: 'annotateit'})
      assert.isTrue(permissions.authorize('read', a))

    it 'should allow an action when the action field contains the authenticated group and the plugin has auth info', ->
      a = annotations[5]
      assert.isFalse(permissions.authorize('update', a))
      permissions.setUser({userId: 'anyone', consumerKey: 'anywhere'})
      assert.isTrue(permissions.authorize('update', a))

    it 'should allow an action when the action field contains the consumer group and the plugin has auth info with a matching consumer', ->
      a = annotations[6]
      assert.isFalse(permissions.authorize('read', a))
      permissions.setUser({userId: 'anyone', consumerKey: 'anywhere'})
      assert.isFalse(permissions.authorize('read', a))
      permissions.setUser({userId: 'anyone', consumerKey: 'annotateit'})
      assert.isTrue(permissions.authorize('read', a))

    it 'should allow an action when the action field contains the consumer group and the plugin has auth info with a matching consumer', ->
      a = annotations[6]
      assert.isFalse(permissions.authorize('read', a))
      permissions.setUser({userId: 'anyone', consumerKey: 'anywhere'})
      assert.isFalse(permissions.authorize('read', a))
      permissions.setUser({userId: 'anyone', consumerKey: 'annotateit'})
      assert.isTrue(permissions.authorize('read', a))

    it 'should allow an action when the user is an admin of the annotation\'s consumer', ->
      a = annotations[2]
      permissions.setUser({userId: 'anyone', consumerKey: 'anywhere', admin: true})
      assert.isFalse(permissions.authorize('read', a))
      permissions.setUser({userId: 'anyone', consumerKey: 'annotateit', admin: true})
      assert.isTrue(permissions.authorize('read', a))
