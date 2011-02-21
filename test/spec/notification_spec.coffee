describe 'Annotator.Notification', ->
  annotator = null

  beforeEach ->
    annotator = new Annotator.Notification()

  afterEach ->
    $(annotator.element).remove()

  it 'should be appended to the document.body', ->
    expect(annotator.element.parentNode).toEqual(document.body)

  describe '.show()', ->
    message = 'This is a notification message'

    beforeEach ->
      annotator.show(message)

    it 'should have a class named "show"', ->
      expect($(annotator.element).hasClass('show')).toBeTruthy()

    it 'should update the notification message', ->
      expect($(annotator.element).html()).toEqual(message)

  describe '.hide()', ->
    beforeEach ->
      annotator.hide()

    it 'should not have a class named "show"', ->
      expect($(annotator.element).hasClass('show')).toBeFalsy()
