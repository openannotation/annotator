var assert = require('assertive-chai').assert;

var $ = require('../../../src/util').$;

var widget = require('../../../src/ui/widget');

describe("ui.widget.Widget", function () {
    var w = null;

    beforeEach(function () {
        w = new widget.Widget();
    });

    describe("constructor", function () {
        it("should extend the Widget#classes object with child classes", function () {
            var ChildWidget = widget.Widget.extend({});
            ChildWidget.classes = {
                customClass: 'my-custom-class',
                anotherClass: 'another-class'
            };

            var child = new ChildWidget();

            assert.deepEqual(child.classes, {
                hide: 'annotator-hide',
                invert: {
                    x: 'annotator-invert-x',
                    y: 'annotator-invert-y'
                },
                customClass: 'my-custom-class',
                anotherClass: 'another-class'
            });
        });
    });

    describe("invertX", function () {
        it("should add the Widget#classes.invert.x class to the widget element", function () {
            w.element.removeClass(w.classes.invert.x);
            w.invertX();
            assert.isTrue(w.element.hasClass(w.classes.invert.x));
        });
    });

    describe("invertY", function () {
        it("should add the Widget#classes.invert.y class to the widget element", function () {
            w.element.removeClass(w.classes.invert.y);
            w.invertY();
            assert.isTrue(w.element.hasClass(w.classes.invert.y));
        });
    });

    describe("isInvertedY", function () {
        it("should return the vertical inverted status of the widget", function () {
            assert.isFalse(w.isInvertedY());
            w.invertY();
            assert.isTrue(w.isInvertedY());
        });
    });

    describe("isInvertedX", function () {
        it("should return the horizontal inverted status of the widget", function () {
            assert.isFalse(w.isInvertedX());
            w.invertX();
            assert.isTrue(w.isInvertedX());
        });
    });

    describe("resetOrientation", function () {
        it("should remove the Widget#classes.invert classes from the widget element", function () {
            w.element.addClass(w.classes.invert.x).addClass(w.classes.invert.y);
            w.resetOrientation();
            assert.isFalse(w.element.hasClass(w.classes.invert.x));
            assert.isFalse(w.element.hasClass(w.classes.invert.y));
        });
    });

    describe("checkOrientation", function () {
        var mocks = [
            // Fits in viewport
            {
                'window': {width: 920, scrollTop: 0, scrollLeft: 0},
                element: {offset: {top: 300, left: 0}, width: 250}
            },
            // Hidden to the right
            {
                'window': {width: 920, scrollTop: 0, scrollLeft: 0},
                element: {offset: {top: 200, left: 900}, width: 250}
            },
            // Hidden to the top
            {
                'window': {width: 920, scrollTop: 0, scrollLeft: 0},
                element: {offset: {top: -100, left: 0}, width: 250}
            },
            // Hidden to the top and right
            {
                'window': {width: 920, scrollTop: 0, scrollLeft: 0},
                element: {offset: {top: -100, left: 900}, width: 250}
            },
            // Hidden at the top due to scrolling Y
            {
                'window': {width: 920, scrollTop: 300, scrollLeft: 0},
                element: {offset: {top: 200, left: 0}, width: 250}
            },
            // Visible to the right due to scrolling X
            {
                'window': {width: 750, scrollTop: 0, scrollLeft: 300},
                element: {offset: {top: 200, left: 750}, width: 250}
            }
        ];

        beforeEach(function () {
            var mock = mocks.shift();

            sinon.stub($.fn, 'init').returns({
                width: sinon.stub().returns(mock.window.width),
                scrollTop: sinon.stub().returns(mock.window.scrollTop),
                scrollLeft: sinon.stub().returns(mock.window.scrollLeft)
            });

            sinon.stub(w.element, 'children').returns({
                offset: sinon.stub().returns(mock.element.offset),
                width: sinon.stub().returns(mock.element.width)
            });

            sinon.stub(w, 'invertX');
            sinon.stub(w, 'invertY');
            sinon.stub(w, 'resetOrientation');

            w.checkOrientation();
        });

        afterEach(function () {
            w.element.children.restore();
            $.fn.init.restore();
        });

        it("should reset the widget each time", function () {
            assert(w.resetOrientation.calledOnce);
            assert.isFalse(w.invertX.called);
            assert.isFalse(w.invertY.called);
        });

        it("should invert the widget if it does not fit horizontally", function () {
            assert(w.invertX.calledOnce);
            assert.isFalse(w.invertY.called);
        });

        it("should invert the widget if it does not fit vertically", function () {
            assert.isFalse(w.invertX.called);
            assert(w.invertY.calledOnce);
        });

        it("should invert the widget if it does not fit horizontally or vertically", function () {
            assert(w.invertX.calledOnce);
            assert(w.invertY.calledOnce);
        });

        it("should invert the widget if it does not fit vertically and the window is scrolled", function () {
            assert.isFalse(w.invertX.called);
            assert(w.invertY.calledOnce);
        });

        it("should invert the widget if it fits horizontally due to the window scrolled", function () {
            assert.isFalse(w.invertX.called);
            assert.isFalse(w.invertY.called);
        });
    });
});
