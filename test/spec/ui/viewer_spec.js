var assert = require('assertive-chai').assert;

var h = require('../../helpers');

var viewer = require('../../../src/ui/viewer'),
    util = require('../../../src/util');

var $ = util.$;

describe('ui.viewer.Viewer', function () {
    var v = null;

    beforeEach(function () {
        h.addFixture('viewer');
    });

    afterEach(function () {
        h.clearFixtures();
    });

    describe('in default configuration', function () {
        beforeEach(function () {
            v = new viewer.Viewer();
            v.attach();
        });

        afterEach(function () {
            v.destroy();
        });

        it('should start hidden', function () {
            assert.isFalse(v.isShown());
        });

        it('should display an external link if the annotation provides one', function () {
            v.load([{
                links: [
                    {rel: "alternate", href: "http://example.com/foo", type: "text/html"},
                    {rel: "default", href: "http://example.com/foo2", type: "application/pdf"},
                    {rel: "alternate", href: "http://example.com/foo3", type: "text/html"},
                    {rel: "default", href: "http://example.com/foo4", type: "text/html"},
                    {rel: "alternate", href: "http://example.com/foo5", type: "application/pdf"}
                ]
            }]);
            assert.equal(v.element.find('.annotator-link').attr('href'), 'http://example.com/foo');
        });

        it("should not display an external link if the annotation doesn't provide a valid one", function () {
            v.load([{
                links: [
                    {rel: "default", href: "http://example.com/foo2", type: "application/pdf"},
                    {rel: "default", href: "http://example.com/foo4", type: "text/html"},
                    {rel: "alternate", href: "http://example.com/foo5", type: "application/pdf"}
                ]
            }]);
            assert.isUndefined(v.element.find('.annotator-link').attr('href'));
        });

        describe('.show()', function () {
            it('should make the viewer widget visible', function () {
                v.show();
                assert.isTrue(v.isShown());
            });

            it('sets the widget position if a position is provided', function () {
                var position = {
                    top: '100px',
                    left: '200px'
                };
                v.show(position);
                assert.deepEqual({
                    top: v.element[0].style.top,
                    left: v.element[0].style.left
                }, position);
            });
        });

        describe('.hide()', function () {
            it('should hide the viewer widget', function () {
                v.show();
                v.hide();
                assert.isFalse(v.isShown());
            });
        });

        describe('.destroy()', function () {
            it('should remove the viewer from the document', function () {
                v.destroy();
                assert.isFalse(v.element.parents().index(document.body) >= 0);
            });
        });

        describe('.load(annotations)', function () {
            it('should show the widget', function () {
                v.load([{text: "Hello, world."}]);
                assert.isTrue(v.isShown());
            });

            it('should show the annotation text (one annotation)', function () {
                v.load([{text: "Hello, world."}]);
                assert.isTrue(v.element.html().indexOf("Hello, world.") >= 0);
            });

            it('should show the annotation text (multiple annotations)', function () {
                v.load([
                    {text: "Penguins with hats"},
                    {text: "Elephants with scarves"}
                ]);
                var html = v.element.html();
                assert.isTrue(html.indexOf("Penguins with hats") >= 0);
                assert.isTrue(html.indexOf("Elephants with scarves") >= 0);
            });
        });

        describe('custom fields', function () {
            var ann = null,
                field = null;

            beforeEach(function () {
                ann = {text: "Donkeys with beachballs"};
                field = {load: sinon.spy()};
                v.addField(field);
            });

            it('should call the load callback of added fields when annotations are loaded into the viewer', function () {
                v.load([ann]);
                sinon.assert.calledOnce(field.load);
            });

            it('should pass a DOM Node as the first argument to the load callback', function () {
                v.load([ann]);
                var callArgs = field.load.args[0];
                assert.equal(callArgs[0].nodeType, 1);
            });

            it('should pass an annotation as the second argument to the load callback', function () {
                v.load([ann]);
                var callArgs = field.load.args[0];
                assert.equal(callArgs[1], ann);
            });

            it('should call the load callback once per annotation', function () {
                var ann2 = {text: "Sharks with laserbeams"};
                v.load([ann, ann2]);
                assert.equal(field.load.callCount, 2);
            });

            it('should insert the field elements into the viewer', function () {
                v.load([ann]);
                var callArgs = field.load.args[0];
                assert.isTrue($(callArgs[0]).parents().index(v.element) >= 0);
            });
        });
    });

    describe('when the permitEdit function returns true', function () {
        var onEdit = null;

        beforeEach(function () {
            onEdit = sinon.stub();
            v = new viewer.Viewer({
                permitEdit: function () { return true; },
                onEdit: onEdit
            });
            v.attach();
        });

        afterEach(function () {
            v.destroy();
        });

        it('should contain an edit button', function () {
            v.load([{text: "Anteaters with torches"}]);
            assert(v.element.find('.annotator-edit'));
        });

        it('should pass a controller for the edit button as the third argument to the load callback of custom fields', function () {
            var field = {
                load: sinon.spy()
            };
            v.addField(field);
            v.load([{text: "Bees with wands"}]);
            var callArgs = field.load.args[0];
            assert.property(callArgs[2], 'showEdit');
            assert.property(callArgs[2], 'hideEdit');
        });

        it('clicking on the edit button should trigger the onEdit callback', function () {
            var ann = {
                text: "Rabbits with cloaks"
            };
            v.load([ann]);
            v.element.find('.annotator-edit').click();
            sinon.assert.calledWith(onEdit, ann);
        });
    });

    describe('when the permitDelete function returns true', function () {
        var onDelete = null;

        beforeEach(function () {
            onDelete = sinon.stub();
            v = new viewer.Viewer({
                permitDelete: function () { return true; },
                onDelete: onDelete
            });
            v.attach();
        });

        afterEach(function () {
            v.destroy();
        });

        it('should contain an delete button', function () {
            v.load([{text: "Anteaters with torches"}]);
            assert(v.element.find('.annotator-delete'));
        });

        it('should pass a controller for the edit button as the third argument to the load callback of custom fields', function () {
            var field = {
                load: sinon.spy()
            };
            v.addField(field);
            v.load([{text: "Bees with wands"}]);
            var callArgs = field.load.args[0];
            assert.property(callArgs[2], 'showDelete');
            assert.property(callArgs[2], 'hideDelete');
        });

        it('clicking on the delete button should trigger an annotation delete', function () {
            var ann = {
                text: "Rabbits with cloaks"
            };
            v.load([ann]);
            v.element.find('.annotator-delete').click();
            sinon.assert.calledWith(onDelete, ann);
        });
    });

    describe('with the defaultFields option set to false', function () {
        beforeEach(function () {
            v = new viewer.Viewer({
                defaultFields: false
            });
            v.attach();
        });

        afterEach(function () {
            v.destroy();
        });

        it('should not add the default fields', function () {
            v.load([{text: "Anteaters with torches"}]);
            assert.equal(v.element.html().indexOf("Anteaters with torches"), -1);
        });
    });

    describe('renderer', function () {
        beforeEach(function () {
            v = new viewer.Viewer();
            v.setRenderer(sinon.stub().returns("Wolves with sheep"));
        });

        afterEach(function () {
            v.destroy();
        });

        it('uses the renderer to render the annotation', function () {
            v.load([{text: "Tigers with cameras"}]);
            var html = v.element.html();
            assert.isTrue(html.indexOf("Wolves with sheep") >= 0);
        });
    });

    describe('event handlers', function () {
        var hl = null,
            clock = null,
            sandbox = null;

        beforeEach(function () {
            v = new viewer.Viewer({
                activityDelay: 50,
                inactivityDelay: 200,
                autoViewHighlights: h.fix()
            });
            v.attach();
            hl = $(h.fix()).find('.annotator-hl.one');
            hl.data('annotation', {
                text: "Cats with mats"
            });
            clock = sinon.useFakeTimers();
            sandbox = sinon.sandbox.create();
        });

        afterEach(function () {
            sandbox.restore();
            clock.restore();
            v.destroy();
        });

        it('should show annotations when a user mouses over a highlight within its element', function () {
            hl.mouseover();
            assert.isTrue(v.isShown());
            assert.isTrue(v.element.html().indexOf("Cats with mats") >= 0);
        });

        it('should redraw the viewer when another highlight is moused over, but only after a short delay (the activityDelay)', function () {
            var hl2 = $(h.fix()).find('.annotator-hl.two');
            hl2.data('annotation', {
                text: "Dogs with bones"
            });
            hl.mouseover();
            hl2.mouseover();
            clock.tick(49);
            assert.isTrue(v.element.html().indexOf("Cats with mats") >= 0);
            clock.tick(2);
            assert.equal(v.element.html().indexOf("Cats with mats"), -1);
            assert.isTrue(v.element.html().indexOf("Dogs with bones") >= 0);
        });

        it('should hide the viewer when the user mouses off the highlight, after a delay (the inactivityDelay)', function () {
            hl.mouseover();
            hl.mouseleave();
            clock.tick(199);
            assert.isTrue(v.isShown());
            clock.tick(2);
            assert.isFalse(v.isShown());
        });

        it('should prevent the viewer from hiding if the user mouses over the viewer', function () {
            hl.mouseover();
            hl.mouseleave();
            clock.tick(199);
            v.element.mouseenter();
            clock.tick(100);
            assert.isTrue(v.isShown());
        });

        it('should hide the viewer when the user mouses off the viewer, after a delay (the inactivityDelay)', function () {
            hl.mouseover();
            hl.mouseleave();
            clock.tick(199);
            v.element.mouseenter();
            v.element.mouseleave();
            clock.tick(199);
            assert.isTrue(v.isShown());
            clock.tick(2);
            assert.isFalse(v.isShown());
        });

        // Regression test: Issue #431
        it('should not interfere with other mouseup and mousedown handlers on the document', function () {
            var doc = h.fix().ownerDocument,
                called = false;
            $(doc)
                .on('mouseup', function () { called = true; })
                .on('mousedown', function () { called = true; });
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
            assert.isTrue(called, 'event should have propagated to the document');
        });

        // Regression test: Issue #520. Repeatedly showing the dialog is
        // surprisingly slow when many annotations overlap.
        it('should only show the viewer once when mousing over overlapping annotations', function() {
            var hl3 = $(h.fix()).find('.annotator-hl.three');
            hl3.data('annotation', {
                text: "Time flies like arrows."
            });

            var hl4 = $(h.fix()).find('.annotator-hl.four');
            hl4.data('annotation', {
                text: "(Is that right?)"
            });

            sandbox.spy(v, 'load');
            sandbox.spy(v, 'show');

            hl4.mouseover();
            clock.tick(200);

            assert.isTrue(v.isShown());
            assert.isTrue(v.element.html().indexOf("Time flies like arrows.") >= 0);
            assert.isTrue(v.element.html().indexOf("(Is that right?)") >= 0);

            assert.equal(v.load.callCount, 1);
            assert.equal(v.show.callCount, 1);
        });
    });
});


describe('ui.viewer.standalone', function () {
    var sandbox;
    var mockAuthz;
    var mockIdent;
    var mockApp;
    var mockViewer;

    beforeEach(function () {
        sandbox = sinon.sandbox.create();
        mockAuthz = {
            permits: sandbox.stub()
        };
        mockIdent = {
            who: sandbox.stub().returns('alice')
        };
        mockApp = {
            annotations: {
                update: sandbox.stub(),
                "delete": sandbox.stub()
            },
            registry: {
                getUtility: sandbox.stub()
            }
        };
        mockApp.registry.getUtility.withArgs('authorizationPolicy').returns(mockAuthz);
        mockApp.registry.getUtility.withArgs('identityPolicy').returns(mockIdent);
        mockViewer = {
            destroy: sandbox.stub()
        };
        sandbox.stub(viewer, 'Viewer').returns(mockViewer);
    });

    afterEach(function () {
        sandbox.restore();
    });

    it('sets a default onEdit handler that calls the storage update function', function () {
        viewer.standalone().start(mockApp);
        var passedOptions = viewer.Viewer.firstCall.args[0];
        assert(sinon.match.has('onEdit').test(passedOptions));
        passedOptions.onEdit({
            text: 'foo'
        });
        sinon.assert.calledWith(mockApp.annotations.update, {
            text: 'foo'
        });
    });

    it('sets a default onDelete handler that calls the storage delete function', function () {
        viewer.standalone().start(mockApp);
        var passedOptions = viewer.Viewer.firstCall.args[0];
        assert(sinon.match.has('onDelete').test(passedOptions));
        passedOptions.onDelete({
            text: 'foo'
        });
        sinon.assert.calledWith(mockApp.annotations["delete"], {
            text: 'foo'
        });
    });

    it('sets a default permitEdit handler that consults the authorization policy', function () {
        viewer.standalone().start(mockApp);
        var passedOptions = viewer.Viewer.firstCall.args[0];
        assert(sinon.match.has('permitEdit').test(passedOptions));
        passedOptions.permitEdit({text: 'foo'});
        sinon.assert.calledWith(
            mockAuthz.permits,
            'update',
            {text: 'foo'},
            'alice'
        );
    });

    it('sets a default permitDelete handler that consults the authorization policy', function () {
        viewer.standalone().start(mockApp);
        var passedOptions = viewer.Viewer.firstCall.args[0];
        assert(sinon.match.has('permitDelete').test(passedOptions));
        passedOptions.permitDelete({text: 'foo'});
        sinon.assert.calledWith(
            mockAuthz.permits,
            'delete',
            {text: 'foo'},
            'alice'
        );
    });

    it('destroys the viewer component when destroyed', function () {
        var plugin = viewer.standalone();
        plugin.start(mockApp);
        plugin.destroy();
        sinon.assert.calledOnce(mockViewer.destroy);
    });
});
