var $, Notification;

Notification = require('../../src/notification');

$ = require('../../src/util').$;

describe('Notification.Banner', function() {
    var notification;
    notification = null;
    beforeEach(function() {
        return notification = Notification.Banner();
    });
    afterEach(function() {
        return $(document.body).find('.annotator-notice').remove();
    });
    describe('.create()', function() {
        return it('creates a new notification object', function() {
            var n;
            n = notification.create('hello world');
            return assert.ok(n);
        });
    });
    return describe('the returned notification object', function() {
        var clock, message, n;
        n = null;
        clock = null;
        message = 'This is a notification message';
        beforeEach(function() {
            n = notification.create(message);
            return clock = sinon.useFakeTimers();
        });
        afterEach(function() {
            return clock.restore();
        });
        it('has an element that is visible in the document body', function() {
            return assert.equal(n.element.parentNode, document.body);
        });
        it('has the correct notification message', function() {
            return assert.equal(n.element.innerHTML, message);
        });
        it('has an element with the annotator-notice-info class by default', function() {
            return assert.match(n.element.className, /\bannotator-notice-info\b/);
        });
        it('has an element with the annotator-notice-success class if the severity was Notification.SUCCESS', function() {
            n = notification.create(message, Notification.SUCCESS);
            return assert.match(n.element.className, /\bannotator-notice-success\b/);
        });
        it('has an element with the annotator-notice-error class if the severity was Notification.ERROR', function() {
            n = notification.create(message, Notification.ERROR);
            return assert.match(n.element.className, /\bannotator-notice-error\b/);
        });
        return it('has a close method which hides the notification', function() {
            n.close();
            clock.tick(600);
            return assert.isNull(n.element.parentNode);
        });
    });
});
