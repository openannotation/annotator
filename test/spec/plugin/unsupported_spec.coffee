Annotator = require('annotator')
Unsupported = require('../../../src/plugin/unsupported').Unsupported


describe 'Unsupported plugin', ->

  it 'should notify the user if Annotator does not support the current
      browser', ->
    mockRegistry = {
      notification: {
        create: sinon.stub()
      }
    }

    sinon.stub(Annotator, 'supported').returns(false)

    plug = Unsupported(mockRegistry)
    sinon.assert.calledOnce(mockRegistry.notification.create)
