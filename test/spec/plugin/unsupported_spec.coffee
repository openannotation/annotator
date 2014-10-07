var Annotator, Unsupported;

Annotator = require('annotator');

Unsupported = require('../../../src/plugin/unsupported').Unsupported;

describe('Unsupported plugin', function() {
    return it('should notify the user if Annotator does not support the current browser', function() {
        var mockRegistry, plug;
        mockRegistry = {
            notification: {
                create: sinon.stub()
            }
        };
        sinon.stub(Annotator, 'supported').returns({
            supported: false,
            errors: ['widgets are discombobulated']
        });
        plug = Unsupported(mockRegistry);
        return sinon.assert.calledWith(mockRegistry.notification.create, sinon.match('widgets are discombobulated'));
    });
});
