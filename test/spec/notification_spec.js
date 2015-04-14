var assert = require('assertive-chai').assert;

var notification = require('../../src/notification');

describe('notification.banner', function () {
    afterEach(function () {
        var el = document.querySelector('.annotator-notice');
        if (el) {
            el.parentNode.removeChild(el);
        }
    });

    it('creates a new banner object', function () {
        var b = notification.banner('hello world');
        assert.ok(b);
    });

    describe('the banner element', function () {
        it('has the correct notifier message', function () {
            notification.banner('This is a notification message');
            var el = document.querySelector('.annotator-notice');
            assert.equal(el.innerHTML, 'This is a notification message');
        });

        it('has the annotator-notice-info class by default', function () {
            notification.banner('normal');
            var el = document.querySelector('.annotator-notice');
            assert.match(el.className, /\bannotator-notice-info\b/);
        });

        it('has the annotator-notice-success class if the severity was notification.SUCCESS', function () {
            notification.banner('yay!', notification.SUCCESS);
            var el = document.querySelector('.annotator-notice');
            assert.match(el.className, /\bannotator-notice-success\b/);
        });

        it('has the annotator-notice-error class if the severity was notification.ERROR', function () {
            notification.banner('oops!', notification.ERROR);
            var el = document.querySelector('.annotator-notice');
            assert.match(el.className, /\bannotator-notice-error\b/);
        });
    });

    describe('the banner object', function () {
        it('has a close method which hides the notifier', function () {
            var clock = sinon.useFakeTimers();
            var b = notification.banner('This is a notification message');
            b.close();
            clock.tick(600);
            var el = document.querySelector('.annotator-notice');
            assert.isNull(el);
            clock.restore();
        });
    });
});
