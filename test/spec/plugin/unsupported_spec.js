var annotator = require('annotator'),
    Unsupported = require('../../../src/plugin/unsupported').Unsupported;

describe('Unsupported plugin', function () {
    it('should notify the user if Annotator does not support the current browser', function () {
        var mockRegistry = {
            notifier: {
                show: sinon.stub()
            }
        };
        sinon.stub(annotator, 'supported').returns({
            supported: false,
            errors: ['widgets are discombobulated']
        });

        Unsupported(mockRegistry);
        sinon.assert.calledWith(
            mockRegistry.notifier.show,
            sinon.match('widgets are discombobulated')
        );
    });
});
