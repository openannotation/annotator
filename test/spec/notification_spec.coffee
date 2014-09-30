Notification = require('../../src/notification')
$ = require('../../src/util').$


describe 'Notification.Banner', ->
  notification = null

  beforeEach ->
    notification = Notification.Banner()

  afterEach ->
    $(document.body).find('.annotator-notice').remove()

  describe '.create()', ->
    it 'creates a new notification object', ->
      n = notification.create('hello world')
      assert.ok(n)

  describe 'the returned notification object', ->
    n = null
    clock = null
    message = 'This is a notification message'

    beforeEach ->
      n = notification.create(message)
      clock = sinon.useFakeTimers()

    afterEach ->
      clock.restore()

    it 'has an element that is visible in the document body', ->
      assert.equal(n.element.parentNode, document.body)

    it 'has the correct notification message', ->
      assert.equal(n.element.innerHTML, message)

    it 'has an element with the annotator-notice-info class by default', ->
      assert.match(n.element.className, /\bannotator-notice-info\b/)

    it 'has an element with the annotator-notice-success class if the severity
        was Notification.SUCCESS', ->
      n = notification.create(message, Notification.SUCCESS)
      assert.match(n.element.className, /\bannotator-notice-success\b/)

    it 'has an element with the annotator-notice-error class if the severity
        was Notification.ERROR', ->
      n = notification.create(message, Notification.ERROR)
      assert.match(n.element.className, /\bannotator-notice-error\b/)

    it 'has a close method which hides the notification', ->
      n.close()
      clock.tick(600)
      assert.isNull(n.element.parentNode)
