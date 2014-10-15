var h = require('helpers');

var Util = require('../../../src/util'),
    $ = Util.$;

var DefaultUI = require('../../../src/plugin/defaultui').DefaultUI,
    UI = require('../../../src/ui');

describe('DefaultUI plugin', function () {
    var sandbox;

    beforeEach(function () {
        sandbox = sinon.sandbox.create();
    });

    afterEach(function () {
        sandbox.restore();
    });

    it('should add CSS to the document that ensures annotator elements have a suitably high z-index', function () {
        h.addFixture('annotator');
        var $fix = $(h.fix());
        $fix.show();

        var $adder = $('<div style="position:relative;" class="annotator-adder">&nbsp;</div>').appendTo($fix);
        var $filter = $('<div style="position:relative;" class="annotator-filter">&nbsp;</div>').appendTo($fix);

        function check(minimum) {
            var adderZ, filterZ;
            adderZ = parseInt($adder.css('z-index'), 10);
            filterZ = parseInt($filter.css('z-index'), 10);
            assert.operator(adderZ, '>', minimum);
            assert.operator(filterZ, '>', minimum);
            return assert.operator(adderZ, '>', filterZ);
        }

        var plug = DefaultUI(h.fix())(null);
        check(1000);

        $fix.append('<div style="position: relative; z-index: 2000"></div>');
        plug = DefaultUI(h.fix())(null);
        check(2000);
    });

    describe("Adder", function () {
        var el, mockAdder, mockRegistry, plug;

        beforeEach(function () {
            el = $('<div></div>')[0];
            mockAdder = {destroy: sandbox.stub()};
            mockRegistry = {annotations: {create: sandbox.stub()}};
            sandbox.stub(UI, 'Adder').returns(mockAdder);

            plug = DefaultUI(el)(mockRegistry);
        });

        it("creates an Adder", function () {
            sinon.assert.calledOnce(UI.Adder);
        });

        it("passes an onCreate handler which asks the registry to create an annotation", function () {
            var callArgs = UI.Adder.args[0];
            assert.property(callArgs[0], 'onCreate');
            callArgs[0].onCreate({text: 'wibble'});
            sinon.assert.calledWith(
                mockRegistry.annotations.create,
                {text: 'wibble'}
            );
        });
    });

    describe("Editor", function () {
        var el, mockEditor, mockRegistry, plug;

        beforeEach(function () {
            el = $('<div></div>')[0];
            mockEditor = {
                addField: sandbox.stub(),
                destroy: sandbox.stub()
            };
            mockRegistry = {
                annotations: {create: sandbox.stub()},
                authorizer: {
                    permits: sandbox.stub().returns(true),
                    userId: function (u) { return u; }
                },
                identifier: {who: sandbox.stub().returns('alice')}
            };
            sandbox.stub(UI, 'Editor').returns(mockEditor);

            plug = DefaultUI(el)(mockRegistry);
        });

        it("creates an Editor", function () {
            sinon.assert.calledOnce(UI.Editor);
        });

        it("adds permissions-related fields", function () {
            sinon.assert.callCount(mockEditor.addField, 2);
        });

        describe("permissions field load/submit functions", function () {
            var field;
            var viewLoad, viewSubmit;

            beforeEach(function () {
                viewLoad = mockEditor.addField.args[0][0].load;
                viewSubmit = mockEditor.addField.args[0][0].submit;

                field = $('<div><input type="checkbox" disabled></div>')[0];
            });

            it("load hides a field if no user is set", function () {
                mockRegistry.identifier.who.returns(null);
                viewLoad(field, {});
                assert.equal(field.style.display, 'none');
            });

            it("load hides a field if current user is not admin", function () {
                var ann = {};
                mockRegistry.authorizer.permits
                    .withArgs('admin', ann, 'alice').returns(false);
                viewLoad(field, ann);
                assert.equal(field.style.display, 'none');
            });

            it("load hides a field if current user is not admin", function () {
                var ann = {};
                mockRegistry.authorizer.permits
                    .withArgs('admin', ann, 'alice').returns(false);
                viewLoad(field, ann);
                assert.equal(field.style.display, 'none');
            });

            it("load shows a checked field if the action is authorised with a null user", function () {
                mockRegistry.authorizer.permits.returns(true);
                viewLoad(field, {});
                assert.notEqual(field.style.display, 'none');
                assert.isTrue(field.firstChild.checked);
            });

            it("load shows an unchecked field if the action isn't authorised with a null user", function () {
                var ann = {};
                mockRegistry.authorizer.permits
                    .withArgs('read', ann, null).returns(false);
                viewLoad(field, ann);
                assert.notEqual(field.style.display, 'none');
                assert.isFalse(field.firstChild.checked);
            });

            it("submit deletes the permissions field for the action if the checkbox is checked", function () {
                var ann = {permissions: {'read': ['alice']}};
                field.firstChild.checked = true;
                viewSubmit(field, ann);
                assert.notProperty(ann.permissions, 'read');
            });

            it("submit sets the permissions field for the action to [userId] if the checkbox is unchecked", function () {
                var ann = {};
                field.firstChild.checked = false;
                viewSubmit(field, ann);
                assert.property(ann, 'permissions');
                assert.property(ann.permissions, 'read');
                assert.deepEqual(ann.permissions.read, ['alice']);
            });

            it("submit doesn't touch the annotation if the current user is null", function () {
                mockRegistry.identifier.who.returns(null);
                var ann = {permissions: {'read': ['alice']}};
                field.firstChild.checked = true;
                viewSubmit(field, ann);
                assert.deepEqual(ann.permissions, {'read': ['alice']});
            });
        });
    });

    describe('text selections', function () {
        var el, mockAdder, mockHighlighter, onSelection, plug, ranges;

        beforeEach(function () {
            el = $('<div>Party in space</div>')[0];
            mockAdder = {load: sinon.stub()};
            mockHighlighter = {draw: sandbox.stub(), undraw: sandbox.stub()};
            sandbox.stub(UI, 'Adder').returns(mockAdder);
            sandbox.stub(UI, 'Highlighter').returns(mockHighlighter);
            sandbox.stub(UI, 'TextSelector', function (elem, options) {
                onSelection = options.onSelection;
            });
            sandbox.stub(Util, 'mousePosition');
            plug = DefaultUI(el)();
            ranges = [
                {
                    text: sinon.stub().returns('party'),
                    serialize: sinon.stub().returns('range 1')
                },
                {
                    text: sinon.stub().returns('in space'),
                    serialize: sinon.stub().returns('range 2')
                }
            ];
            onSelection(ranges, event);
        });

        it('should show the adder', function () {
            sinon.assert.calledOnce(mockAdder.load);
        });

        it('should serialize the selected ranges', function () {
            var match = sinon.match({ranges: ['range 1', 'range 2']});
            sinon.assert.calledWith(mockAdder.load, match);
        });

        it('should extract the selected quote', function () {
            var match = sinon.match({quote: 'party / in space'});
            sinon.assert.calledWith(mockAdder.load, match);
        });
    });

    describe('text highlights', function () {
        var el, mockAdder, mockHighlighter, plug;

        beforeEach(function () {
            el = $('<div>Party in space</div>')[0];
            mockAdder = {load: sinon.stub(), hide: sinon.stub()};
            mockHighlighter = {draw: sandbox.stub(), undraw: sandbox.stub()};
            sandbox.stub(UI, 'Adder').returns(mockAdder);
            sandbox.stub(UI, 'Highlighter').returns(mockHighlighter);
            plug = DefaultUI(el)();
        });

        describe('when annotations are created', function () {
            var annotation, highlights;

            beforeEach(function () {
                highlights = $('<span></span>').get();
                annotation = {id: 'foo', ranges: []};
                mockHighlighter.draw.returns(highlights);
                plug.onAnnotationCreated(annotation);
            });

            it('should create highlights', function () {
                sinon.assert.calledWith(mockHighlighter.draw, []);
            });

            describe('`_local` property', function () {
                it('should be an Object', function () {
                    assert.isObject(annotation._local);
                });

                it('should have the highlights', function () {
                    assert.equal(annotation._local.highlights, highlights);
                });
            });

            describe('highlights', function () {
                it('should have the `annotation` data', function () {
                    var data = $(highlights).data('annotation');
                    assert.equal(data, annotation);
                });

                it('should have a `data-annotation-id` property', function () {
                    assert.equal(highlights[0].dataset.annotationId, 'foo');
                });
            });
        });

        describe('when annotations are deleted', function () {
            var annotation, highlights;

            beforeEach(function () {
                highlights = $('<span></span>').get();
                annotation = {id: 'foo', ranges: [], _local: {}};
                annotation._local.highlights = highlights;
                plug.onAnnotationDeleted(annotation);
            });

            it('should destroy highlights', function () {
                sinon.assert.calledWith(mockHighlighter.undraw, highlights);
            });

            it('should delete the `_local` property', function () {
                assert.isUndefined(annotation._local);
            });
        });

        describe('when annotations are updated', function () {
            var annotation, highlights, newHighlights;

            beforeEach(function () {
                highlights = $('<span></span>').get();
                newHighlights = $('<span></span>').get();
                annotation = {id: 'foo', ranges: [], _local: {}};
                annotation._local.highlights = highlights;
                mockHighlighter.draw.returns(newHighlights);
                plug.onAnnotationUpdated(annotation);
            });

            it('should update the highlights', function () {
                sinon.assert.calledWith(mockHighlighter.undraw, highlights);
                sinon.assert.calledWith(mockHighlighter.draw, []);
            });
        });

        describe('when annotations are loaded', function () {
            var annotations, promise;

            beforeEach(function () {
                annotations = [{}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}];
                annotations.forEach(function (a, i) {
                    a.id = 'foo' + i;
                    a.ranges = [];
                    var highlights = $('<span></span>').get();
                    mockHighlighter.draw.onCall(i).returns(highlights);
                });
                promise = plug.onAnnotationsLoaded(annotations);
            });

            it('should promise to set up all the annotations', function (done) {
                promise.then(function (results) {
                    assert.deepEqual(results, annotations);
                    results.forEach(function (a) {
                        assert.isObject(a._local);
                        var highlights = a._local.highlights;
                        assert.isArray(highlights);
                        assert.equal($(highlights).data('annotation'), a);
                        assert.equal(highlights[0].dataset.annotationId, a.id);
                    });
                })
                .then(done, done);
            });
        });
    });

    it("should destroy the UI components when it is destroyed", function () {
        var mockAdder = {destroy: sandbox.stub()},
            mockEditor = {addField: sandbox.stub(), destroy: sandbox.stub()},
            mockHighlighter = {destroy: sandbox.stub()},
            mockTextSelector = {destroy: sandbox.stub()},
            mockViewer = {destroy: sandbox.stub()};
        sandbox.stub(UI, 'Adder').returns(mockAdder);
        sandbox.stub(UI, 'Editor').returns(mockEditor);
        sandbox.stub(UI, 'Highlighter').returns(mockHighlighter);
        sandbox.stub(UI, 'TextSelector').returns(mockTextSelector);
        sandbox.stub(UI, 'Viewer').returns(mockViewer);
        var plug = DefaultUI(null)(null);
        plug.onDestroy();
        sinon.assert.calledOnce(mockAdder.destroy);
        sinon.assert.calledOnce(mockEditor.destroy);
        sinon.assert.calledOnce(mockHighlighter.destroy);
        sinon.assert.calledOnce(mockTextSelector.destroy);
        sinon.assert.calledOnce(mockViewer.destroy);
    });
});
