var $, UI, Util, h,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

h = require('helpers');

UI = require('../../../src/ui');

Util = require('../../../src/util');

$ = Util.$;

describe('UI.Adder', function() {
    var a, onCreate;
    a = null;
    onCreate = null;
    beforeEach(function() {
        h.addFixture('adder');
        onCreate = sinon.stub();
        return a = new UI.Adder({
            onCreate: onCreate
        });
    });
    afterEach(function() {
        a.destroy();
        return h.clearFixtures();
    });
    it('should start hidden', function() {
        return assert.isFalse(a.isShown());
    });
    describe('.show()', function() {
        it('should make the adder widget visible', function() {
            a.show();
            return assert.isTrue(a.element.is(':visible'));
        });
        return it('sets the widget position if a position is provided', function() {
            var position;
            position = {
                top: '100px',
                left: '200px'
            };
            a.show(position);
            return assert.deepEqual({
                top: a.element[0].style.top,
                left: a.element[0].style.left
            }, position);
        });
    });
    describe('.hide()', function() {
        return it('should hide the adder widget', function() {
            a.show();
            a.hide();
            return assert.isFalse(a.element.is(':visible'));
        });
    });
    describe('.isShown()', function() {
        it('should return true if the adder is shown', function() {
            a.show();
            return assert.isTrue(a.isShown());
        });
        return it('should return false if the adder is hidden', function() {
            a.hide();
            return assert.isFalse(a.isShown());
        });
    });
    describe('.destroy()', function() {
        return it('should remove the adder from the document', function() {
            var _ref;
            a.destroy();
            return assert.isFalse((_ref = document.body, __indexOf.call(a.element.parents(), _ref) >= 0));
        });
    });
    describe('.load()', function() {
        var ann;
        ann = null;
        beforeEach(function() {
            return ann = {
                text: 'foo'
            };
        });
        it("shows the widget", function() {
            a.load(ann);
            return assert.isTrue(a.isShown());
        });
        return it("sets the widget position if a position is provided", function() {
            var position;
            position = {
                top: '123px',
                left: '456px'
            };
            a.load(ann, position);
            return assert.deepEqual({
                top: a.element[0].style.top,
                left: a.element[0].style.left
            }, position);
        });
    });
    return describe('event handlers', function() {
        var ann;
        ann = null;
        beforeEach(function() {
            ann = {
                text: 'foo'
            };
            return a.load(ann);
        });
        it("calls the onCreate handler when the button is left-clicked", function() {
            a.element.find('button').trigger({
                type: 'click',
                which: 1
            });
            return sinon.assert.calledWith(onCreate, ann);
        });
        it("does not call the onCreate handler when the button is right-clicked", function() {
            a.element.find('button').trigger({
                type: 'click',
                which: 3
            });
            return sinon.assert.notCalled(onCreate);
        });
        it("passes the triggering event to the onCreate handler", function() {
            a.element.find('button').trigger({
                type: 'click',
                which: 1
            });
            return assert.equal(onCreate.firstCall.args[1].type, 'click');
        });
        return it("hides the adder when the button is left-clicked", function() {
            $(Util.getGlobal().document.body).trigger('mouseup');
            a.element.find('button').trigger({
                type: 'click',
                which: 1
            });
            return assert.isFalse(a.isShown());
        });
    });
});
