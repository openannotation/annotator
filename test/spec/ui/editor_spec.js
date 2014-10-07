var $, Editor, Range, Util, h,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

h = require('helpers');

Range = require('xpath-range').Range;

Editor = require('.../../../src/ui/editor');

Util = require('../../../src/util');

$ = Util.$;

describe('UI.Editor.Editor', function() {
    var plugin;
    plugin = null;
    describe('in default configuration', function() {
        beforeEach(function() {
            return plugin = new Editor.Editor();
        });
        afterEach(function() {
            return plugin.destroy();
        });
        it('should start hidden', function() {
            return assert.isFalse(plugin.isShown());
        });
        describe('.show()', function() {
            it('should make the editor widget visible', function() {
                plugin.show();
                return assert.isTrue(plugin.isShown());
            });
            return it('sets the widget position if a position is provided', function() {
                plugin.show({
                    top: '100px',
                    left: '200px'
                });
                return assert.deepEqual({
                    top: plugin.element[0].style.top,
                    left: plugin.element[0].style.left
                }, {
                    top: '100px',
                    left: '200px'
                });
            });
        });
        describe('.hide()', function() {
            return it('should hide the editor widget', function() {
                plugin.show();
                plugin.hide();
                return assert.isFalse(plugin.isShown());
            });
        });
        describe('.destroy()', function() {
            return it('should remove the editor from the document', function() {
                var _ref;
                plugin.destroy();
                return assert.isFalse((_ref = document.body, __indexOf.call(plugin.element.parents(), _ref) >= 0));
            });
        });
        describe('.load(annotation)', function() {
            it('should show the widget', function() {
                plugin.load({
                    text: "Hello, world."
                });
                return assert.isTrue(plugin.isShown());
            });
            it('should show the annotation text for editing', function() {
                plugin.load({
                    text: "Hello, world."
                });
                return assert.equal(plugin.element.find('textarea').val(), "Hello, world.");
            });
            it('should return a promise that is resolved if the editor is subsequently submitted', function(done) {
                var ann, res;
                ann = {
                    text: "Hello, world"
                };
                res = plugin.load(ann);
                plugin.element.find('textarea').val('Updated in the editor');
                plugin.submit();
                return res.then(function() {
                    return assert.equal(ann.text, "Updated in the editor");
                }).then(done, done);
            });
            return it('should return a promise that is rejected if editing is subsequently cancelled', function(done) {
                var ann, res;
                ann = {
                    text: "Hello, world"
                };
                res = plugin.load(ann);
                plugin.cancel();
                return res.then(function() {
                    return done(new Error("Promise should have been rejected!"));
                }, function() {
                    return done();
                });
            });
        });
        describe('.submit()', function() {
            var ann;
            ann = null;
            beforeEach(function() {
                ann = {
                    text: "Giraffes are tall."
                };
                return plugin.load(ann);
            });
            it('should hide the widget', function() {
                plugin.submit();
                return assert.isFalse(plugin.isShown());
            });
            return it('should save any changes made to the annotation text', function() {
                plugin.element.find('textarea').val('Lions are strong.');
                plugin.submit();
                return assert.equal(ann.text, 'Lions are strong.');
            });
        });
        describe('.cancel()', function() {
            var ann;
            ann = null;
            beforeEach(function() {
                ann = {
                    text: "Blue whales are large."
                };
                return plugin.load(ann);
            });
            it('should hide the widget', function() {
                plugin.submit();
                return assert.isFalse(plugin.isShown());
            });
            return it('should NOT save changes made to the annotation text', function() {
                plugin.element.find('textarea').val('Mice are small.');
                plugin.cancel();
                return assert.equal(ann.text, 'Blue whales are large.');
            });
        });
        return describe('custom fields', function() {
            var ann, elem, field;
            ann = null;
            field = null;
            elem = null;
            beforeEach(function() {
                ann = {
                    text: "Donkeys with beachballs"
                };
                field = {
                    label: "Example field",
                    load: sinon.spy(),
                    submit: sinon.spy()
                };
                return elem = plugin.addField(field);
            });
            it('should call the load callback of added fields when an annotation is loaded into the editor', function() {
                plugin.load(ann);
                return sinon.assert.calledOnce(field.load);
            });
            it('should pass a DOM Node as the first argument to the load callback', function() {
                var callArgs;
                plugin.load(ann);
                callArgs = field.load.args[0];
                return assert.equal(callArgs[0].nodeType, 1);
            });
            it('should pass an annotation as the second argument to the load callback', function() {
                var callArgs;
                plugin.load(ann);
                callArgs = field.load.args[0];
                return assert.equal(callArgs[1], ann);
            });
            it('should return the created field element from .addField(field)', function() {
                return assert.equal(elem.nodeType, 1);
            });
            it('should add the plugin label to the field element', function() {
                return assert($(elem).html().indexOf('Example field') >= 0);
            });
            it('should add an <input> element by default', function() {
                return assert.equal($(elem).find(':input').prop('tagName'), 'INPUT');
            });
            it('should add a <textarea> element if type is "textarea"', function() {
                var elem2;
                elem2 = plugin.addField({
                    label: "My textarea",
                    type: "textarea",
                    load: function() {},
                    submit: function() {}
                });
                return assert.equal($(elem2).find(':input').prop('tagName'), 'TEXTAREA');
            });
            it('should add a <select> element if type is "select"', function() {
                var elem2;
                elem2 = plugin.addField({
                    label: "My select",
                    type: "select",
                    load: function() {},
                    submit: function() {}
                });
                return assert.equal($(elem2).find(':input').prop('tagName'), 'SELECT');
            });
            it('should add an <input type="checkbox"> element if type is "checkbox"', function() {
                var elem2;
                elem2 = plugin.addField({
                    label: "My checkbox",
                    type: "checkbox",
                    load: function() {},
                    submit: function() {}
                });
                assert.equal($(elem2).find(':input').prop('tagName'), 'INPUT');
                return assert.equal($(elem2).find(':input').attr('type'), 'checkbox');
            });
            it('should call the submit callback of added fields when the editor is submitted', function() {
                plugin.load(ann);
                plugin.submit();
                return sinon.assert.calledOnce(field.submit);
            });
            it('should pass a DOM Node as the first argument to the submit callback', function() {
                var callArgs;
                plugin.load(ann);
                plugin.submit();
                callArgs = field.submit.args[0];
                return assert.equal(callArgs[0].nodeType, 1);
            });
            return it('should pass an annotation as the second argument to the load callback', function() {
                var callArgs;
                plugin.load(ann);
                plugin.submit();
                callArgs = field.submit.args[0];
                return assert.equal(callArgs[1], ann);
            });
        });
    });
    describe('with the defaultFields option set to false', function() {
        beforeEach(function() {
            return plugin = new Editor.Editor({
                defaultFields: false
            });
        });
        afterEach(function() {
            return plugin.destroy();
        });
        return it('should not add the default fields', function() {
            plugin.load({
                text: "Anteaters with torches"
            });
            return assert.equal(plugin.element.html().indexOf("Anteaters with torches"), -1);
        });
    });
    return describe('event handlers', function() {
        var ann;
        ann = null;
        beforeEach(function() {
            plugin = new Editor.Editor();
            return ann = {
                text: 'Turtles with armbands'
            };
        });
        afterEach(function() {
            return plugin.destroy();
        });
        it('should submit when the editor form is submitted', function() {
            plugin.load(ann);
            plugin.element.find('textarea').val('Turtles with bandanas');
            plugin.element.find('form').submit();
            assert.equal(ann.text, 'Turtles with bandanas');
            return assert.isFalse(plugin.isShown());
        });
        it('should submit when the editor submit button is clicked', function() {
            plugin.load(ann);
            plugin.element.find('textarea').val('Turtles with bandanas');
            plugin.element.find('.annotator-save').click();
            assert.equal(ann.text, 'Turtles with bandanas');
            return assert.isFalse(plugin.isShown());
        });
        it('should cancel editing when the editor cancel button is clicked', function() {
            plugin.load(ann);
            plugin.element.find('textarea').val('Turtles with bandanas');
            plugin.element.find('.annotator-cancel').click();
            assert.equal(ann.text, 'Turtles with armbands');
            return assert.isFalse(plugin.isShown());
        });
        it('should submit when the user hits <Return> in the main textarea', function() {
            plugin.load(ann);
            plugin.element.find('textarea').val('Turtles with bandanas').trigger({
                type: 'keydown',
                which: 13
            });
            assert.equal(ann.text, 'Turtles with bandanas');
            return assert.isFalse(plugin.isShown());
        });
        it('should NOT submit when the user hits <Shift>-<Return> in the main textarea', function() {
            plugin.load(ann);
            plugin.element.find('textarea').val('Turtles with bandanas').trigger({
                type: 'keydown',
                which: 13,
                shiftKey: true
            });
            assert.equal(ann.text, 'Turtles with armbands');
            return assert.isTrue(plugin.isShown());
        });
        return it('should cancel editing when the user hits <Esc> in the main textarea', function() {
            plugin.load(ann);
            plugin.element.find('textarea').val('Turtles with bandanas').trigger({
                type: 'keydown',
                which: 27
            });
            assert.equal(ann.text, 'Turtles with armbands');
            return assert.isFalse(plugin.isShown());
        });
    });
});

describe('Editor.dragTracker', function() {
    var $handle, callback, clock, dt, mouseDown, mouseMove, mouseUp;
    $handle = null;
    callback = null;
    clock = null;
    dt = null;
    beforeEach(function() {
        $handle = $('<div/>');
        callback = sinon.stub();
        clock = sinon.useFakeTimers();
        // Needs to be in a document
        $handle.appendTo(h.fix());
        return dt = Editor.dragTracker($handle[0], callback);
    });
    afterEach(function() {
        clock.restore();
        return h.clearFixtures();
    });
    mouseDown = function(x, y) {
        if (x == null) {
            x = 0;
        }
        if (y == null) {
            y = 0;
        }
        return $handle.trigger({
            type: 'mousedown',
            pageX: x,
            pageY: y,
            target: $handle[0]
        });
    };
    mouseMove = function(x, y) {
        if (x == null) {
            x = 0;
        }
        if (y == null) {
            y = 0;
        }
        return $handle.trigger({
            type: 'mousemove',
            pageX: x,
            pageY: y
        });
    };
    mouseUp = function(x, y) {
        if (x == null) {
            x = 0;
        }
        if (y == null) {
            y = 0;
        }
        return $handle.trigger({
            type: 'mouseup',
            pageX: x,
            pageY: y
        });
    };
    it('does not track when the mouse button is up', function() {
        mouseMove(5, 10);
        return sinon.assert.notCalled(callback);
    });
    it('starts tracking when the mouse button is down', function() {
        mouseDown();
        mouseMove(5, 10);
        return sinon.assert.calledOnce(callback);
    });
    it('stops tracking when the mouse button is raised again', function() {
        mouseDown();
        mouseUp();
        mouseMove(5, 10);
        return sinon.assert.notCalled(callback);
    });
    it('stops tracking when destroyed', function() {
        dt.destroy();
        mouseDown();
        mouseMove(5, 10);
        return sinon.assert.notCalled(callback);
    });
    it('calls the callback with an object that contains the distance moved since the last call', function() {
        mouseDown();
        mouseMove(5, 10);
        sinon.assert.calledWith(callback, {
            x: 5,
            y: 10
        });
        clock.tick(20);
        mouseMove(8, 12);
        sinon.assert.calledWith(callback, {
            x: 3,
            y: 2
        });
        clock.tick(20);
        mouseMove(0, 0);
        return sinon.assert.calledWith(callback, {
            x: -8,
            y: -12
        });
    });
    it('accumulates the distance moved if the callback returns false', function() {
        mouseDown();
        callback.returns(false);
        mouseMove(10, 10);
        sinon.assert.calledWith(callback, {
            x: 10,
            y: 10
        });
        clock.tick(20);
        mouseMove(20, 20);
        return sinon.assert.calledWith(callback, {
            x: 20,
            y: 20
        });
    });
    return it('throttles calls to the callback to 60Hz (once every 16ms)', function() {
        mouseDown();
        mouseMove(0, 0);
        mouseMove(10, 10);
        assert.equal(callback.callCount, 1);
        clock.tick(10);
        mouseMove(11, 11);
        assert.equal(callback.callCount, 1);
        clock.tick(16);
        mouseMove(20, 20);
        return assert.equal(callback.callCount, 2);
    });
});

describe('Editor.mover', function() {
    var $element, $handle, m, mouseDown, mouseMove;
    $element = null;
    $handle = null;
    m = null;
    beforeEach(function() {
        $element = $('<div/>');
        $handle = $('<div/>');
        // Needs to be in a document
        $element.appendTo(h.fix());
        $handle.appendTo(h.fix());
        // Needs to be responsive to setting top/left CSS properties
        $element.css({
            position: 'absolute'
        });
        return m = Editor.mover($element[0], $handle[0]);
    });
    afterEach(function() {
        return h.clearFixtures();
    });
    mouseDown = function(x, y) {
        if (x == null) {
            x = 0;
        }
        if (y == null) {
            y = 0;
        }
        return $handle.trigger({
            type: 'mousedown',
            pageX: x,
            pageY: y,
            target: $handle[0]
        });
    };
    mouseMove = function(x, y) {
        if (x == null) {
            x = 0;
        }
        if (y == null) {
            y = 0;
        }
        return $handle.trigger({
            type: 'mousemove',
            pageX: x,
            pageY: y
        });
    };
    return it('moves the element when the handle is dragged', function() {
        var after;
        $element.css({
            top: 42,
            left: 123
        });
        mouseDown();
        mouseMove(456, 123);
        after = {
            top: parseInt($element.css('top'), 10),
            left: parseInt($element.css('left'), 10)
        };
        assert.equal(after.top, 42 + 123);
        return assert.equal(after.left, 123 + 456);
    });
});

describe('Editor.resizer', function() {
    var $element, $handle, mouseDown, mouseMove, options, r;
    $element = null;
    $handle = null;
    options = null;
    r = null;
    beforeEach(function() {
        $element = $('<div/>');
        $handle = $('<div/>');
        // Needs to be in a document
        $element.appendTo(h.fix());
        $handle.appendTo(h.fix());
        options = {
            invertedX: sinon.stub().returns(false),
            invertedY: sinon.stub().returns(false)
        };
        return r = Editor.resizer($element[0], $handle[0], options);
    });
    afterEach(function() {
        return h.clearFixtures();
    });
    mouseDown = function(x, y) {
        if (x == null) {
            x = 0;
        }
        if (y == null) {
            y = 0;
        }
        return $handle.trigger({
            type: 'mousedown',
            pageX: x,
            pageY: y,
            target: $handle[0]
        });
    };
    mouseMove = function(x, y) {
        if (x == null) {
            x = 0;
        }
        if (y == null) {
            y = 0;
        }
        return $handle.trigger({
            type: 'mousemove',
            pageX: x,
            pageY: y
        });
    };
    it('resizes the element when the handle is dragged', function() {
        var afterHeight, afterWidth;
        $element.height(42).width(123);
        mouseDown();
        mouseMove(456, -123);
        afterHeight = $element.height();
        afterWidth = $element.width();
        assert.equal(afterHeight, 42 + 123);
        return assert.equal(afterWidth, 123 + 456);
    });
    it('inverts the horizontal sense of the drag when invertedX returns true', function() {
        var afterHeight, afterWidth;
        $element.height(42).width(123);
        options.invertedX.returns(true);
        mouseDown();
        mouseMove(-456, -123);
        afterHeight = $element.height();
        afterWidth = $element.width();
        assert.equal(afterHeight, 42 + 123);
        return assert.equal(afterWidth, 123 + 456);
    });
    return it('inverts the vertical sense of the drag when invertedY returns true', function() {
        var afterHeight, afterWidth;
        $element.height(42).width(123);
        options.invertedY.returns(true);
        mouseDown();
        mouseMove(456, 123);
        afterHeight = $element.height();
        afterWidth = $element.width();
        assert.equal(afterHeight, 42 + 123);
        return assert.equal(afterWidth, 123 + 456);
    });
});
