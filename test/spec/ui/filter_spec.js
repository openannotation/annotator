var assert = require('assertive-chai').assert;

var filter = require('../../../src/ui/filter'),
    util = require('../../../src/util');

var $ = util.$;

describe('ui.filter.Filter', function () {
    var plugin = null,
        element = null,
        sandbox = null;

    beforeEach(function () {
        element = $('<div />')[0];
        plugin = new filter.Filter({
            filterElement: element
        });
        sandbox = sinon.sandbox.create();
    });

    afterEach(function () {
        plugin.destroy();
        sandbox.restore();
    });

    describe("default configuration", function () {
        it("should have a default annotation filter", function () {
            assert.equal(plugin.filters.length, 1);
            assert.equal(plugin.filters[0].property, "text");
        });

        it("should append the toolbar to the @options.appendTo selector", function () {
            var parent = $(plugin.options.appendTo);
            assert.equal(plugin.element.parent()[0], parent[0]);
        });
    });

    describe("addFilter", function () {
        var testFilter = null;

        beforeEach(function () {
            plugin.filters = [];
            testFilter = {
                label: 'Tag',
                property: 'tags'
            };
            plugin.addFilter(testFilter);
        });

        it("should add a filter object to Filter#plugins", function () {
            assert.ok(plugin.filters[0]);
        });

        it("should append the html to Filter#toolbar", function () {
            testFilter = plugin.filters[0];
            assert.equal(testFilter.element[0], plugin.element.find('#annotator-filter-tags').parent()[0]);
        });

        it("should store the filter in the elements data store under 'filter'", function () {
            testFilter = plugin.filters[0];
            assert.equal(testFilter.element.data('filter'), plugin.filters[0]);
        });

        it("should not add a filter for a property that has already been loaded", function () {
            plugin.addFilter({
                label: 'Tag',
                property: 'tags'
            });
            assert.lengthOf(plugin.filters, 1);
        });
    });

    describe("passing filters to constructor", function () {
        var testFilter = null;

        beforeEach(function () {
            testFilter = {
                label: 'Tag',
                property: 'tags'
            };
            plugin = new filter.Filter({
                filterElement: element,
                filters: [testFilter],
                addAnnotationFilter: false
            });
        });

        it("should add a filter object to Filter#plugins", function () {
            assert.ok(plugin.filters[0]);
        });

        it("should append the html to Filter#toolbar", function () {
            testFilter = plugin.filters[0];
            assert.equal(testFilter.element[0], plugin.element.find('#annotator-filter-tags').parent()[0]);
        });

        it("should store the filter in the elements data store under 'filter'", function () {
            testFilter = plugin.filters[0];
            assert.equal(testFilter.element.data('filter'), plugin.filters[0]);
        });

        it("should not add a filter for a property that has already been loaded", function () {
            plugin.addFilter({
                label: 'Tag',
                property: 'tags'
            });
            assert.lengthOf(plugin.filters, 1);
        });
    });

    describe("updateFilter", function () {
        var testFilter = null,
            annotations = null;

        beforeEach(function () {
            testFilter = {
                id: 'text',
                label: 'Annotation',
                property: 'text',
                element: $('<span><input value="ca" /></span>'),
                annotations: [],
                isFiltered: function (value, text) {
                    return text.indexOf('ca') !== -1;
                }
            };
            annotations = [{text: 'cat'}, {text: 'dog'}, {text: 'car'}];
            plugin.filters = {'text': testFilter};
            plugin.highlights = $('<span>cat</span><span>dog</span><span>car</span>');
            plugin.highlights.each(function(i) {
                $(this).data('annotation', annotations[i]);
            });
            sandbox.stub(plugin, 'updateHighlights');
            sandbox.stub(plugin, 'resetHighlights');
            sandbox.stub(plugin, 'filterHighlights');
        });

        it("should call Filter#updateHighlights()", function () {
            plugin.updateFilter(testFilter);
            assert(plugin.updateHighlights.calledOnce);
        });

        it("should call Filter#resetHighlights()", function () {
            plugin.updateFilter(testFilter);
            assert(plugin.resetHighlights.calledOnce);
        });

        it("should filter the cat and car annotations", function () {
            plugin.updateFilter(testFilter);
            assert.deepEqual(testFilter.annotations, [annotations[0], annotations[2]]);
        });

        it("should call Filter#filterHighlights()", function () {
            plugin.updateFilter(testFilter);
            assert(plugin.filterHighlights.calledOnce);
        });

        it("should NOT call Filter#filterHighlights() if there is no input", function () {
            testFilter.element.find('input').val('');
            plugin.updateFilter(testFilter);
            assert.isFalse(plugin.filterHighlights.called);
        });
    });

    describe("filterHighlights", function () {
        var div = null;

        beforeEach(function () {
            plugin.highlights = $('<span /><span /><span /><span /><span />');
            // This annotation appears in both filters
            var match = {
                _local: {
                    highlights: [plugin.highlights[1]]
                }
            };
            plugin.filters = [
                {
                    annotations: [
                        {_local: {highlights: [plugin.highlights[0]]}},
                        match
                    ]
                },
                {
                    annotations: [
                        {_local: {highlights: [plugin.highlights[4]]}},
                        match,
                        {_local: {highlights: [plugin.highlights[2]]}}
                    ]
                }
            ];
            div = $('<div>').append(plugin.highlights);
        });

        it("should hide all highlights not whitelisted by _every_ filter", function () {
            plugin.filterHighlights();
            // Only index 1 should remain
            assert.lengthOf(div.find('.' + plugin.classes.hl.hide), 4);
        });

        it("should hide all highlights not whitelisted by _every_ filter if every filter is active", function () {
            plugin.filters[1].annotations = [];
            plugin.filterHighlights();
            assert.lengthOf(div.find('.' + plugin.classes.hl.hide), 3);
        });

        it("should hide all highlights not whitelisted if only one filter", function () {
            plugin.filters = plugin.filters.slice(0, 1);
            plugin.filterHighlights();
            assert.lengthOf(div.find('.' + plugin.classes.hl.hide), 3);
        });
    });

    describe("resetHighlights", function () {
        it("should remove the filter-hide class from all highlights", function () {
            plugin.highlights = $('<span /><span /><span />').addClass(plugin.classes.hl.hide);
            plugin.resetHighlights();
            assert.lengthOf(plugin.highlights.filter('.' + plugin.classes.hl.hide), 0);
        });
    });

    describe("group: filter input actions", function () {
        describe("_onFilterFocus", function () {
            it("should add an active class to the element", function () {
                plugin._onFilterFocus({
                    target: plugin.filter.find('input')[0]
                });
                assert.isTrue(plugin.filter.hasClass(plugin.classes.active));
            });
        });

        describe("_onFilterBlur", function () {
            it("should remove the active class from the element", function () {
                plugin.filter.addClass(plugin.classes.active);
                plugin._onFilterBlur({
                    target: plugin.filter.find('input')[0]
                });
                assert.isFalse(plugin.filter.hasClass(plugin.classes.active));
            });

            it("should NOT remove the active class from the element if it has a value", function () {
                plugin.filter.addClass(plugin.classes.active);
                plugin._onFilterBlur({
                    target: plugin.filter.find('input').val('filtered')[0]
                });
                assert.isTrue(plugin.filter.hasClass(plugin.classes.active));
            });
        });

        describe("_onFilterKeyup", function () {
            beforeEach(function () {
                plugin.filters = [
                    {label: 'My Filter'}
                ];
                sandbox.stub(plugin, 'updateFilter');
            });

            it("should call Filter#updateFilter() with the relevant filter", function () {
                plugin.filter.data('filter', plugin.filters[0]);
                plugin._onFilterKeyup({
                    target: plugin.filter.find('input')[0]
                }, $);
                assert.isTrue(plugin.updateFilter.calledWith(plugin.filters[0]));
            });

            it("should NOT call Filter#updateFilter() if no filter is found", function () {
                plugin._onFilterKeyup({
                    target: plugin.filter.find('input')[0]
                });
                assert.isFalse(plugin.updateFilter.called);
            });
        });

        describe("navigation", function () {
            var element1 = null,
                element2 = null,
                element3 = null,
                annotation1 = null,
                annotation2 = null,
                annotation3 = null;

            beforeEach(function () {
                element1 = $('<span />');
                annotation1 = {
                    text: 'annotation1',
                    _local: {
                        highlights: [element1[0]]
                    }
                };
                element1.data('annotation', annotation1);
                element2 = $('<span />');
                annotation2 = {
                    text: 'annotation2',
                    _local: {
                        highlights: [element2[0]]
                    }
                };
                element2.data('annotation', annotation2);
                element3 = $('<span />');
                annotation3 = {
                    text: 'annotation3',
                    _local: {
                        highlights: [element3[0]]
                    }
                };
                element3.data('annotation', annotation3);
                plugin.highlights = $([element1[0], element2[0], element3[0]]);
                sandbox.spy(plugin, '_scrollToHighlight');
            });

            describe("_onNextClick", function () {
                it("should advance to the next element", function () {
                    element2.addClass(plugin.classes.hl.active);
                    plugin._onNextClick();
                    assert.isTrue(plugin._scrollToHighlight.calledWith([element3[0]]));
                });

                it("should loop back to the start once it gets to the end", function () {
                    element3.addClass(plugin.classes.hl.active);
                    plugin._onNextClick();
                    assert.isTrue(plugin._scrollToHighlight.calledWith([element1[0]]));
                });

                it("should use the first element if there is no current element", function () {
                    plugin._onNextClick();
                    assert.isTrue(plugin._scrollToHighlight.calledWith([element1[0]]));
                });

                it("should only navigate through non hidden elements", function () {
                    element1.addClass(plugin.classes.hl.active);
                    element2.addClass(plugin.classes.hl.hide);
                    plugin._onNextClick();
                    assert.isTrue(plugin._scrollToHighlight.calledWith([element3[0]]));
                });

                it("should do nothing if there are no annotations", function () {
                    plugin.highlights = $();
                    plugin._onNextClick();
                    assert.isFalse(plugin._scrollToHighlight.called);
                });
            });

            describe("_onPreviousClick", function () {
                it("should advance to the previous element", function () {
                    element3.addClass(plugin.classes.hl.active);
                    plugin._onPreviousClick();
                    assert.isTrue(plugin._scrollToHighlight.calledWith([element2[0]]));
                });

                it("should loop to the end once it gets to the beginning", function () {
                    element1.addClass(plugin.classes.hl.active);
                    plugin._onPreviousClick();
                    assert.isTrue(plugin._scrollToHighlight.calledWith([element3[0]]));
                });

                it("should use the last element if there is no current element", function () {
                    plugin._onPreviousClick();
                    assert.isTrue(plugin._scrollToHighlight.calledWith([element3[0]]));
                });

                it("should only navigate through non hidden elements", function () {
                    element3.addClass(plugin.classes.hl.active);
                    element2.addClass(plugin.classes.hl.hide);
                    plugin._onPreviousClick();
                    assert.isTrue(plugin._scrollToHighlight.calledWith([element1[0]]));
                });

                it("should do nothing if there are no annotations", function () {
                    plugin.highlights = $();
                    plugin._onPreviousClick();
                    assert.isFalse(plugin._scrollToHighlight.called);
                });
            });
        });

        describe("_scrollToHighlight", function () {
            var mockjQuery = null;

            beforeEach(function () {
                plugin.highlights = $();
                mockjQuery = {
                    addClass: sandbox.spy(),
                    animate: sandbox.spy(),
                    offset: sandbox.stub().returns({
                        top: 0
                    })
                };
                sandbox.spy(plugin.highlights, 'removeClass');
                sandbox.stub($.prototype, 'init').returns(mockjQuery);
            });

            afterEach(function () {
                $.prototype.init.restore();
            });

            it("should remove active class from currently active element", function () {
                plugin._scrollToHighlight({});
                assert.isTrue(plugin.highlights.removeClass.calledWith(plugin.classes.hl.active));
            });

            it("should add active class to provided elements", function () {
                plugin._scrollToHighlight({});
                assert.isTrue(mockjQuery.addClass.calledWith(plugin.classes.hl.active));
            });

            it("should animate the scrollbar to the highlight offset", function () {
                plugin._scrollToHighlight({});
                assert(mockjQuery.offset.calledOnce);
                assert(mockjQuery.animate.calledOnce);
            });
        });

        describe("_onClearClick", function () {
            var mockjQuery = null;

            beforeEach(function () {
                mockjQuery = {};
                mockjQuery.val = sandbox.stub().returns(mockjQuery);
                mockjQuery.prev = sandbox.stub().returns(mockjQuery);
                mockjQuery.keyup = sandbox.stub().returns(mockjQuery);
                mockjQuery.blur = sandbox.stub().returns(mockjQuery);
                sandbox.stub($.prototype, 'init').returns(mockjQuery);
                plugin._onClearClick({
                    target: {}
                });
            });

            afterEach(function () {
                $.prototype.init.restore();
            });

            it("should clear the input", function () {
                assert.isTrue(mockjQuery.val.calledWith(''));
            });

            it("should trigger the blur event", function () {
                assert(mockjQuery.blur.calledOnce);
            });

            it("should trigger the keyup event", function () {
                assert(mockjQuery.keyup.calledOnce);
            });
        });
    });
});


describe('ui.filter.standalone', function () {
    var mockFilter = null,
        plugin = null,
        sandbox = null;

    beforeEach(function () {
        sandbox = sinon.sandbox.create();
        mockFilter = {
            updateHighlights: sandbox.stub(),
            destroy: sandbox.stub()
        };

        sandbox.stub(filter, 'Filter').returns(mockFilter);

        plugin = filter.standalone();
    });

    afterEach(function () {
        sandbox.restore();
    });

    var hooks = [
        'annotationsLoaded',
        'annotationCreated',
        'annotationUpdated',
        'annotationDeleted'
    ];

    function testHook(h) {
        return function () {
            plugin[h]({text: 123});
            sinon.assert.calledWith(mockFilter.updateHighlights);
        };
    }

    for (var i = 0, len = hooks.length; i < len; i++) {
        it(
            "calls updateHighlights on the filter component " + hooks[i],
            testHook(hooks[i])
        );
    }

    it('destroys the filter component when destroyed', function () {
        plugin.destroy();
        sinon.assert.calledOnce(mockFilter.destroy);
    });
});
