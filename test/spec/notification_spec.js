var Notification = require('../../src/notification'),
    $ = require('../../src/util').$;

describe('Notification.Banner', function () {
    var notification = null;

    beforeEach(function () {
        notification = Notification.Banner();
    });

    afterEach(function () {
        $(document.body).find('.annotator-notice').remove();
    });

    describe('.create()', function () {
        it('creates a new notification object', function () {
            var n = notification.create('hello world');
            assert.ok(n);
        });
    });

    describe('the returned notification object', function () {
        var n = null,
            clock = null,
            message = 'This is a notification message';

        beforeEach(function () {
            n = notification.create(message);
            clock = sinon.useFakeTimers();
        });

        afterEach(function () {
            clock.restore();
        });

        it('has an element that is visible in the document body', function () {
            assert.equal(n.element.parentNode, document.body);
        });

        it('has the correct notification message', function () {
            assert.equal(n.element.innerHTML, message);
        });

        it('has an element with the annotator-notice-info class by default', function () {
            assert.match(n.element.className, /\bannotator-notice-info\b/);
        });

        it('has an element with the annotator-notice-success class if the severity was Notification.SUCCESS', function () {
            n = notification.create(message, Notification.SUCCESS);
            assert.match(n.element.className, /\bannotator-notice-success\b/);
        });

        it('has an element with the annotator-notice-error class if the severity was Notification.ERROR', function () {
            n = notification.create(message, Notification.ERROR);
            assert.match(n.element.className, /\bannotator-notice-error\b/);
        });

        it('has a close method which hides the notification', function () {
            n.close();
            clock.tick(600);
            assert.isNull(n.element.parentNode);
        });
    });
});
