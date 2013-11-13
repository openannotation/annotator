describe 'Annotator.Notification', ->
  notification = null

  beforeEach ->
    notification = new Annotator.Notification()

  afterEach ->
    notification.element.remove()

  it 'should be appended to the document.body', ->
    assert.equal(notification.element[0].parentNode, document.body)

  describe '.show()', ->
    message = 'This is a notification message'

    beforeEach ->
      notification.show(message)

    it 'should have a class named "annotator-notice-show"', ->
      assert.isTrue(notification.element.hasClass('annotator-notice-show'))

    it 'should have a class named "annotator-notice-info"', ->
      assert.isTrue(notification.element.hasClass('annotator-notice-info'))

    it 'should update the notification message', ->
      assert.equal(notification.element.html(), message)

  describe '.hide()', ->
    beforeEach ->
      notification.show()
      notification.hide()

    it 'should not have a class named "annotator-notice-show"', ->
      assert.isFalse(notification.element.hasClass('annotator-notice-show'))

    it 'should not have a class named "annotator-notice-info"', ->
      assert.isFalse(notification.element.hasClass('annotator-notice-info'))
