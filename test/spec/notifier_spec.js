var assert = require('assertive-chai').assert;

var Notifier = require('../../src/notifier'),
    $ = require('../../src/util').$;

describe('Notifier.Banner', function () {
    var notifier = null;

    beforeEach(function () {
        notifier = Notifier.Banner();
    });

    afterEach(function () {
        $(document.body).find('.annotator-notice').remove();
    });

    describe('.show()', function () {
        it('creates a new notifier object', function () {
            var n = notifier.show('hello world');
            assert.ok(n);
        });
    });

    describe('the returned notifier object', function () {
        var n = null,
            clock = null,
            message = 'This is a notifier message';

        beforeEach(function () {
            n = notifier.show(message);
            clock = sinon.useFakeTimers();
        });

        afterEach(function () {
            clock.restore();
        });

        it('has an element that is visible in the document body', function () {
            assert.equal(n.element.parentNode, document.body);
        });

        it('has the correct notifier message', function () {
            assert.equal(n.element.innerHTML, message);
        });

        it('has an element with the annotator-notice-info class by default', function () {
            assert.match(n.element.className, /\bannotator-notice-info\b/);
        });

        it('has an element with the annotator-notice-success class if the severity was Notifier.SUCCESS', function () {
            n = notifier.show(message, Notifier.SUCCESS);
            assert.match(n.element.className, /\bannotator-notice-success\b/);
        });

        it('has an element with the annotator-notice-error class if the severity was Notifier.ERROR', function () {
            n = notifier.show(message, Notifier.ERROR);
            assert.match(n.element.className, /\bannotator-notice-error\b/);
        });

        it('has a close method which hides the notifier', function () {
            n.close();
            clock.tick(600);
            assert.isNull(n.element.parentNode);
        });
    });
});
