var assert = require('assertive-chai').assert;

var $ = require('../../../src/util').$;

var UI = require('../../../src/ui');

describe("UI.Widget", function () {
    var widget = null;

    beforeEach(function () {
        widget = new UI.Widget();
    });

    describe("constructor", function () {
        it("should extend the Widget#classes object with child classes", function () {
            var ChildWidget = UI.Widget.extend({});
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
        it("should add the Widget#classes.invert.x class to the Widget#widget", function () {
            widget.element.removeClass(widget.classes.invert.x);
            widget.invertX();
            assert.isTrue(widget.element.hasClass(widget.classes.invert.x));
        });
    });

    describe("invertY", function () {
        it("should add the Widget#classes.invert.y class to the Widget#widget", function () {
            widget.element.removeClass(widget.classes.invert.y);
            widget.invertY();
            assert.isTrue(widget.element.hasClass(widget.classes.invert.y));
        });
    });

    describe("isInvertedY", function () {
        it("should return the vertical inverted status of the Widget", function () {
            assert.isFalse(widget.isInvertedY());
            widget.invertY();
            assert.isTrue(widget.isInvertedY());
        });
    });

    describe("isInvertedX", function () {
        it("should return the horizontal inverted status of the Widget", function () {
            assert.isFalse(widget.isInvertedX());
            widget.invertX();
            assert.isTrue(widget.isInvertedX());
        });
    });

    describe("resetOrientation", function () {
        it("should remove the Widget#classes.invert classes from the Widget#widget", function () {
            widget.element.addClass(widget.classes.invert.x).addClass(widget.classes.invert.y);
            widget.resetOrientation();
            assert.isFalse(widget.element.hasClass(widget.classes.invert.x));
            assert.isFalse(widget.element.hasClass(widget.classes.invert.y));
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

            sinon.stub(widget.element, 'children').returns({
                offset: sinon.stub().returns(mock.element.offset),
                width: sinon.stub().returns(mock.element.width)
            });

            sinon.stub(widget, 'invertX');
            sinon.stub(widget, 'invertY');
            sinon.stub(widget, 'resetOrientation');

            widget.checkOrientation();
        });

        afterEach(function () {
            widget.element.children.restore();
            $.fn.init.restore();
        });

        it("should reset the widget each time", function () {
            assert(widget.resetOrientation.calledOnce);
            assert.isFalse(widget.invertX.called);
            assert.isFalse(widget.invertY.called);
        });

        it("should invert the widget if it does not fit horizontally", function () {
            assert(widget.invertX.calledOnce);
            assert.isFalse(widget.invertY.called);
        });

        it("should invert the widget if it does not fit vertically", function () {
            assert.isFalse(widget.invertX.called);
            assert(widget.invertY.calledOnce);
        });

        it("should invert the widget if it does not fit horizontally or vertically", function () {
            assert(widget.invertX.calledOnce);
            assert(widget.invertY.calledOnce);
        });

        it("should invert the widget if it does not fit vertically and the window is scrolled", function () {
            assert.isFalse(widget.invertX.called);
            assert(widget.invertY.calledOnce);
        });

        it("should invert the widget if it fits horizontally due to the window scrolled", function () {
            assert.isFalse(widget.invertX.called);
            assert.isFalse(widget.invertY.called);
        });
    });
});
