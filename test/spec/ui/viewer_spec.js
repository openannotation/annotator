var $, Range, UI, Util, h,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

h = require('helpers');

Range = require('xpath-range').Range;

UI = require('../../../src/ui');

Util = require('../../../src/util');

$ = Util.$;

describe('UI.Viewer', function() {
    var v;
    v = null;
    beforeEach(function() {
        return h.addFixture('viewer');
    });
    afterEach(function() {
        return h.clearFixtures();
    });
    describe('in default configuration', function() {
        beforeEach(function() {
            return v = new UI.Viewer();
        });
        afterEach(function() {
            return v.destroy();
        });
        it('should start hidden', function() {
            return assert.isFalse(v.isShown());
        });
        it('should display an external link if the annotation provides one', function() {
            v.load([
                {
                    links: [
                        {
                            rel: "alternate",
                            href: "http://example.com/foo",
                            type: "text/html"
                        }, {
                            rel: "default",
                            href: "http://example.com/foo2",
                            type: "application/pdf"
                        }, {
                            rel: "alternate",
                            href: "http://example.com/foo3",
                            type: "text/html"
                        }, {
                            rel: "default",
                            href: "http://example.com/foo4",
                            type: "text/html"
                        }, {
                            rel: "alternate",
                            href: "http://example.com/foo5",
                            type: "application/pdf"
                        }
                    ]
                }
            ]);
            return assert.equal(v.element.find('.annotator-link').attr('href'), 'http://example.com/foo');
        });
        it("should not display an external link if the annotation doesn't provide a valid one", function() {
            v.load([
                {
                    links: [
                        {
                            rel: "default",
                            href: "http://example.com/foo2",
                            type: "application/pdf"
                        }, {
                            rel: "default",
                            href: "http://example.com/foo4",
                            type: "text/html"
                        }, {
                            rel: "alternate",
                            href: "http://example.com/foo5",
                            type: "application/pdf"
                        }
                    ]
                }
            ]);
            return assert.isUndefined(v.element.find('.annotator-link').attr('href'));
        });
        describe('.show()', function() {
            it('should make the viewer widget visible', function() {
                v.show();
                return assert.isTrue(v.isShown());
            });
            return it('sets the widget position if a position is provided', function() {
                var position;
                position = {
                    top: '100px',
                    left: '200px'
                };
                v.show(position);
                return assert.deepEqual({
                    top: v.element[0].style.top,
                    left: v.element[0].style.left
                }, position);
            });
        });
        describe('.hide()', function() {
            return it('should hide the viewer widget', function() {
                v.show();
                v.hide();
                return assert.isFalse(v.isShown());
            });
        });
        describe('.destroy()', function() {
            return it('should remove the viewer from the document', function() {
                var _ref;
                v.destroy();
                return assert.isFalse((_ref = document.body, __indexOf.call(v.element.parents(), _ref) >= 0));
            });
        });
        describe('.load(annotations)', function() {
            it('should show the widget', function() {
                v.load([
                    {
                        text: "Hello, world."
                    }
                ]);
                return assert.isTrue(v.isShown());
            });
            it('should show the annotation text (one annotation)', function() {
                v.load([
                    {
                        text: "Hello, world."
                    }
                ]);
                return assert.isTrue(v.element.html().indexOf("Hello, world.") >= 0);
            });
            return it('should show the annotation text (multiple annotations)', function() {
                var html;
                v.load([
                    {
                        text: "Penguins with hats"
                    }, {
                        text: "Elephants with scarves"
                    }
                ]);
                html = v.element.html();
                assert.isTrue(html.indexOf("Penguins with hats") >= 0);
                return assert.isTrue(html.indexOf("Elephants with scarves") >= 0);
            });
        });
        return describe('custom fields', function() {
            var ann, field;
            ann = null;
            field = null;
            beforeEach(function() {
                ann = {
                    text: "Donkeys with beachballs"
                };
                field = {
                    load: sinon.spy()
                };
                return v.addField(field);
            });
            it('should call the load callback of added fields when annotations are loaded into the viewer', function() {
                v.load([ann]);
                return sinon.assert.calledOnce(field.load);
            });
            it('should pass a DOM Node as the first argument to the load callback', function() {
                var callArgs;
                v.load([ann]);
                callArgs = field.load.args[0];
                return assert.equal(callArgs[0].nodeType, 1);
            });
            it('should pass an annotation as the second argument to the load callback', function() {
                var callArgs;
                v.load([ann]);
                callArgs = field.load.args[0];
                return assert.equal(callArgs[1], ann);
            });
            it('should call the load callback once per annotation', function() {
                var ann2;
                ann2 = {
                    text: "Sharks with laserbeams"
                };
                v.load([ann, ann2]);
                return assert.equal(field.load.callCount, 2);
            });
            return it('should insert the field elements into the viewer', function() {
                var callArgs, _ref;
                v.load([ann]);
                callArgs = field.load.args[0];
                return assert.isTrue((_ref = v.element[0], __indexOf.call($(callArgs[0]).parents(), _ref) >= 0));
            });
        });
    });
    describe('with the showEditButton option set to true', function() {
        var onEdit;
        onEdit = null;
        beforeEach(function() {
            onEdit = sinon.stub();
            return v = new UI.Viewer({
                showEditButton: true,
                onEdit: onEdit
            });
        });
        afterEach(function() {
            return v.destroy();
        });
        it('should contain an edit button', function() {
            v.load([
                {
                    text: "Anteaters with torches"
                }
            ]);
            return assert(v.element.find('.annotator-edit'));
        });
        it('should pass a controller for the edit button as the third argument to the load callback of custom fields', function() {
            var callArgs, field;
            field = {
                load: sinon.spy()
            };
            v.addField(field);
            v.load([
                {
                    text: "Bees with wands"
                }
            ]);
            callArgs = field.load.args[0];
            assert.property(callArgs[2], 'showEdit');
            return assert.property(callArgs[2], 'hideEdit');
        });
        return it('clicking on the edit button should trigger the onEdit callback', function() {
            var ann;
            ann = {
                text: "Rabbits with cloaks"
            };
            v.load([ann]);
            v.element.find('.annotator-edit').click();
            return sinon.assert.calledWith(onEdit, ann);
        });
    });
    describe('with the showDeleteButton option set to true', function() {
        var onDelete;
        onDelete = null;
        beforeEach(function() {
            onDelete = sinon.stub();
            return v = new UI.Viewer({
                showDeleteButton: true,
                onDelete: onDelete
            });
        });
        afterEach(function() {
            return v.destroy();
        });
        it('should contain an delete button', function() {
            v.load([
                {
                    text: "Anteaters with torches"
                }
            ]);
            return assert(v.element.find('.annotator-delete'));
        });
        it('should pass a controller for the edit button as the third argument to the load callback of custom fields', function() {
            var callArgs, field;
            field = {
                load: sinon.spy()
            };
            v.addField(field);
            v.load([
                {
                    text: "Bees with wands"
                }
            ]);
            callArgs = field.load.args[0];
            assert.property(callArgs[2], 'showDelete');
            return assert.property(callArgs[2], 'hideDelete');
        });
        return it('clicking on the delete button should trigger an annotation delete', function() {
            var ann;
            ann = {
                text: "Rabbits with cloaks"
            };
            v.load([ann]);
            v.element.find('.annotator-delete').click();
            return sinon.assert.calledWith(onDelete, ann);
        });
    });
    describe('with the defaultFields option set to false', function() {
        beforeEach(function() {
            return v = new UI.Viewer({
                defaultFields: false
            });
        });
        afterEach(function() {
            return v.destroy();
        });
        return it('should not add the default fields', function() {
            v.load([
                {
                    text: "Anteaters with torches"
                }
            ]);
            return assert.equal(v.element.html().indexOf("Anteaters with torches"), -1);
        });
    });
    return describe('event handlers', function() {
        var clock, hl;
        hl = null;
        clock = null;
        beforeEach(function() {
            v = new UI.Viewer({
                activityDelay: 50,
                inactivityDelay: 200,
                autoViewHighlights: h.fix()
            });
            hl = $(h.fix()).find('.annotator-hl.one');
            hl.data('annotation', {
                text: "Cats with mats"
            });
            return clock = sinon.useFakeTimers();
        });
        afterEach(function() {
            clock.restore();
            return v.destroy();
        });
        it('should show annotations when a user mouses over a highlight within its element', function() {
            hl.mouseover();
            assert.isTrue(v.isShown());
            return assert.isTrue(v.element.html().indexOf("Cats with mats") >= 0);
        });
        it('should redraw the viewer when another highlight is moused over, but only after a short delay (the activityDelay)', function() {
            var hl2;
            hl2 = $(h.fix()).find('.annotator-hl.two');
            hl2.data('annotation', {
                text: "Dogs with bones"
            });
            hl.mouseover();
            hl2.mouseover();
            clock.tick(49);
            assert.isTrue(v.element.html().indexOf("Cats with mats") >= 0);
            clock.tick(2);
            assert.equal(v.element.html().indexOf("Cats with mats"), -1);
            return assert.isTrue(v.element.html().indexOf("Dogs with bones") >= 0);
        });
        it('should hide the viewer when the user mouses off the highlight, after a delay (the inactivityDelay)', function() {
            hl.mouseover();
            hl.mouseleave();
            clock.tick(199);
            assert.isTrue(v.isShown());
            clock.tick(2);
            return assert.isFalse(v.isShown());
        });
        it('should prevent the viewer from hiding if the user mouses over the viewer', function() {
            hl.mouseover();
            hl.mouseleave();
            clock.tick(199);
            v.element.mouseenter();
            clock.tick(100);
            return assert.isTrue(v.isShown());
        });
        it('should hide the viewer when the user mouses off the viewer, after a delay (the inactivityDelay)', function() {
            hl.mouseover();
            hl.mouseleave();
            clock.tick(199);
            v.element.mouseenter();
            v.element.mouseleave();
            clock.tick(199);
            assert.isTrue(v.isShown());
            clock.tick(2);
            return assert.isFalse(v.isShown());
        });
        // Regression test: Issue #431
        return it('should not interfere with other mouseup and mousedown handlers on the document', function() {
            var called, doc;
            doc = h.fix().ownerDocument;
            called = false;
            $(doc).on('mouseup', function() {
                return called = true;
            }).on('mousedown', function() {
                return called = true;
            });
            $(doc.body).trigger({
                type: 'mouseup',
                which: 2
            });
            assert.isTrue(called, 'event should have propagated to the document');
            called = false;
            $(doc.body).trigger({
                type: 'mousedown',
                which: 2
            });
            return assert.isTrue(called, 'event should have propagated to the document');
        });
    });
});
