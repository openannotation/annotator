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

    sinon.stub(Annotator, 'supported').returns({
      supported: false
      errors: ['widgets are discombobulated']
    })

    plug = Unsupported(mockRegistry)
    sinon.assert.calledWith(
      mockRegistry.notification.create,
      sinon.match('widgets are discombobulated')
    )
