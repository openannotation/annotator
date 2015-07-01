var assert = require('assertive-chai').assert;

var h = require('../../helpers');

var adder = require('../../../src/ui/adder'),
    util = require('../../../src/util');

var $ = util.$;

describe('ui.adder.Adder', function () {
    var a = null,
        onCreate = null;

    beforeEach(function () {
        h.addFixture('adder');
        onCreate = sinon.stub();
        a = new adder.Adder({
            onCreate: onCreate
        });
    });

    afterEach(function () {
        a.destroy();
        h.clearFixtures();
    });

    it('should start hidden', function () {
        assert.isFalse(a.isShown());
    });

    describe('.show()', function () {
        it('should show the adder widget', function () {
            a.show();
            assert.isTrue(a.isShown());
        });

        it('sets the widget position if a position is provided', function () {
            var position = {
                top: '100px',
                left: '200px'
            };
            a.show(position);
            assert.deepEqual({
                top: a.element[0].style.top,
                left: a.element[0].style.left
            }, position);
        });
    });

    describe('.hide()', function () {
        it('should hide the adder widget', function () {
            a.show();
            a.hide();
            assert.isFalse(a.isShown());
        });
    });

    describe('.isShown()', function () {
        it('should return true if the adder is shown', function () {
            a.show();
            assert.isTrue(a.isShown());
        });

        it('should return false if the adder is hidden', function () {
            a.hide();
            assert.isFalse(a.isShown());
        });
    });

    describe('.destroy()', function () {
        it('should remove the adder from the document', function () {
            a.destroy();
            assert.isFalse(a.element.parents().index(document.body) >= 0);
        });
    });

    describe('.load()', function () {
        var ann = null;

        beforeEach(function () {
            ann = {text: 'foo'};
        });

        it("shows the widget", function () {
            a.load(ann);
            assert.isTrue(a.isShown());
        });

        it("sets the widget position if a position is provided", function () {
            var position = {
                top: '123px',
                left: '456px'
            };
            a.load(ann, position);
            assert.deepEqual({
                top: a.element[0].style.top,
                left: a.element[0].style.left
            }, position);
        });
    });

    describe('event handlers', function () {
        var ann = null;

        beforeEach(function () {
            ann = {text: 'foo'};
            a.load(ann);
        });

        it("calls the onCreate handler when the button is left-clicked", function () {
            a.element.find('button').trigger({
                type: 'click',
                which: 1
            });
            sinon.assert.calledWith(onCreate, ann);
        });

        it("does not call the onCreate handler when the button is right-clicked", function () {
            a.element.find('button').trigger({
                type: 'click',
                which: 3
            });
            sinon.assert.notCalled(onCreate);
        });

        it("passes the triggering event to the onCreate handler", function () {
            a.element.find('button').trigger({
                type: 'click',
                which: 1
            });
            assert.equal(onCreate.firstCall.args[1].type, 'click');
        });

        it("hides the adder when the button is left-clicked", function () {
            $(global.document.body).trigger('mouseup');
            a.element.find('button').trigger({
                type: 'click',
                which: 1
            });
            assert.isFalse(a.isShown());
        });
    });
});
