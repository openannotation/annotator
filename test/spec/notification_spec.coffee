describe 'Annotator.Notification', ->
  notification = null

  beforeEach ->
    notification = new Annotator.Notification()

  afterEach ->
    notification.element.remove()

  it 'should be appended to the document.body', ->
    expect(notification.element[0].parentNode).toEqual(document.body)

  describe '.show()', ->
    message = 'This is a notification message'

    beforeEach ->
      notification.show(message)

    it 'should have a class named "annotator-notice-show"', ->
      expect(notification.element.hasClass('annotator-notice-show')).toBeTruthy()

    it 'should update the notification message', ->
      expect(notification.element.html()).toEqual(message)

  describe '.hide()', ->
    beforeEach ->
      notification.hide()

    it 'should not have a class named "show"', ->
      expect(notification.element.hasClass('show')).toBeFalsy()
