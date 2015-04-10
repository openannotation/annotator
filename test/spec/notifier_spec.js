var assert = require('assertive-chai').assert;

var notifier = require('../../src/notifier'),
    $ = require('../../src/util').$;

describe('notifier.Banner', function () {
    var n = null;

    beforeEach(function () {
        n = notifier.Banner();
    });

    afterEach(function () {
        $(document.body).find('.annotator-notice').remove();
    });

    describe('.show()', function () {
        it('creates a new notice object', function () {
            var notice = n.show('hello world');
            assert.ok(notice);
        });
    });

    describe('the returned notice object', function () {
        var notice = null,
            clock = null,
            message = 'This is a notifier message';

        beforeEach(function () {
            notice = n.show(message);
            clock = sinon.useFakeTimers();
        });

        afterEach(function () {
            clock.restore();
        });

        it('has an element that is visible in the document body', function () {
            assert.equal(notice.element.parentNode, document.body);
        });

        it('has the correct notifier message', function () {
            assert.equal(notice.element.innerHTML, message);
        });

        it('has an element with the annotator-notice-info class by default', function () {
            assert.match(notice.element.className, /\bannotator-notice-info\b/);
        });

        it('has an element with the annotator-notice-success class if the severity was Notifier.SUCCESS', function () {
            notice = n.show(message, notifier.SUCCESS);
            assert.match(notice.element.className, /\bannotator-notice-success\b/);
        });

        it('has an element with the annotator-notice-error class if the severity was Notifier.ERROR', function () {
            notice = n.show(message, notifier.ERROR);
            assert.match(notice.element.className, /\bannotator-notice-error\b/);
        });

        it('has a close method which hides the notifier', function () {
            notice.close();
            clock.tick(600);
            assert.isNull(notice.element.parentNode);
        });
    });
});
