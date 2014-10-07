var $, Range, UI, Util, h, testData, testDocument;

h = require('helpers');

Range = require('xpath-range').Range;

UI = require('../../../src/ui');

Util = require('../../../src/util');

$ = Util.$;

testDocument = "<div>\n  <p>Hello world!</p>\n  <p>Giraffes like leaves.</p>\n  <ul>\n      <li>First item</li>\n        <li>Second item</li>\n  </ul>\n</div>";

testData = [
    {
        name: 'single element inner',
        annotations: [
            {
                ranges: [
                    {
                        start: '/p[1]',
                        startOffset: 0,
                        end: '/p[1]',
                        endOffset: 12
                    }
                ]
            }
        ],
        highlights: [[0, 'Hello world!']]
    }, {
        name: 'single element subset',
        annotations: [
            {
                ranges: [
                    {
                        start: '/p[2]',
                        startOffset: 9,
                        end: '/p[2]',
                        endOffset: 13
                    }
                ]
            }
        ],
        highlights: [[0, 'like']]
    }, {
        name: 'spanning element boundaries',
        annotations: [
            {
                ranges: [
                    {
                        start: '/p[1]',
                        startOffset: 6,
                        end: '/p[2]',
                        endOffset: 8
                    }
                ]
            }
        ],
        highlights: [[0, 'world!'], [0, 'Giraffes']]
    }, {
        name: 'spanning multiple elements',
        annotations: [
            {
                ranges: [
                    {
                        start: '/p[1]',
                        startOffset: 6,
                        end: '/ul/li[1]',
                        endOffset: 5
                    }
                ]
            }
        ],
        highlights: [[0, 'world!'], [0, 'Giraffes like leaves.'], [0, 'First']]
    }, {
        name: 'multiple overlapping annotations',
        annotations: [
            {
                ranges: [
                    {
                        start: '/p[2]',
                        startOffset: 0,
                        end: '/p[2]',
                        endOffset: 13
                    }
                ]
            }, {
                ranges: [
                    {
                        start: '/p[2]',
                        startOffset: 9,
                        end: '/p[2]',
                        endOffset: 21
                    }
                ]
            }
        ],
        highlights: [[0, 'Giraffes like'], [1, 'like'], [1, ' leaves.']]
    }, {
        name: 'multiple overlapping annotations spanning elements',
        annotations: [
            {
                ranges: [
                    {
                        start: '/p[1]',
                        startOffset: 6,
                        end: '/ul/li[1]',
                        endOffset: 5
                    }
                ]
            }, {
                ranges: [
                    {
                        start: '/ul[1]/li[1]',
                        startOffset: 0,
                        end: '/ul/li[2]',
                        endOffset: 11
                    }
                ]
            }
        ],
        highlights: [[0, 'world!'], [0, 'Giraffes like leaves.'], [0, 'First'], [1, 'First'], [1, ' item'], [1, 'Second item']]
    }
];

describe('UI.Highlighter', function() {
    var elem, hl, i, testFromData, _i, _ref, _results;
    elem = null;
    hl = null;
    beforeEach(function() {
        elem = $(testDocument).get(0);
        return hl = new UI.Highlighter(elem);
    });
    afterEach(function() {
        return hl.destroy();
    });
    describe('.draw(annotation)', function() {
        var ann;
        ann = null;
        beforeEach(function() {
            return ann = {
                id: 'abc123',
                ranges: [
                    {
                        start: '/p[1]',
                        startOffset: 0,
                        end: '/p[1]',
                        endOffset: 12
                    }
                ]
            };
        });
        afterEach(function() {
            var _base;
            return typeof (_base = Range.sniff).restore === "function" ? _base.restore() : void 0;
        });
        it("should return drawn highlights", function() {
            var highlights;
            highlights = hl.draw(ann);
            assert.equal(highlights.length, 1);
            return assert.equal($(highlights[0]).text(), 'Hello world!');
        });
        it("should draw highlights in the hl's element", function() {
            var highlights;
            hl.draw(ann);
            highlights = $(elem).find('.annotator-hl');
            assert.equal(highlights.length, 1);
            return assert.equal(highlights.text(), 'Hello world!');
        });
        it("should set the `annotation` data property of each highlight element to be a reference to the annotation", function() {
            var highlights;
            highlights = hl.draw(ann);
            assert.equal(highlights.length, 1);
            return assert.equal($(highlights[0]).data('annotation'), ann);
        });
        it("should set a `data-annotation-id` data attribute on each highlight with the annotations id, if it has one", function() {
            var highlights;
            highlights = hl.draw(ann);
            assert.equal(highlights.length, 1);
            return assert.equal($(highlights[0]).attr('data-annotation-id'), ann.id);
        });
        return it("should swallow errors if the annotation fails to normalize", function() {
            var e;
            e = new Range.RangeError("typ", "RangeError should have been caught!");
            sinon.stub(Range, 'sniff').returns({
                normalize: sinon.stub().throws(e)
            });
            return hl.draw({
                id: 123,
                ranges: [
                    {
                        fake: 'range'
                    }
                ]
            });
        });
    });
    describe('.undraw(annotation)', function() {
        var ann;
        ann = null;
        beforeEach(function() {
            ann = {
                id: 'abc123',
                ranges: [
                    {
                        start: '/p[1]',
                        startOffset: 0,
                        end: '/p[1]',
                        endOffset: 12
                    }
                ]
            };
            return hl.draw(ann);
        });
        return it("should remove any highlights stored on the annotation", function() {
            var highlights;
            hl.undraw(ann);
            highlights = $(elem).find('.annotator-hl');
            return assert.equal(highlights.length, 0);
        });
    });
    describe('.redraw(annotation)', function() {
        var ann;
        ann = null;
        beforeEach(function() {
            ann = {
                id: 'abc123',
                ranges: [
                    {
                        start: '/p[1]',
                        startOffset: 0,
                        end: '/p[1]',
                        endOffset: 12
                    }
                ]
            };
            return hl.draw(ann);
        });
        it("should redraw any drawn highlights", function() {
            var highlights;
            ann.id = 'elephants';
            hl.redraw(ann);
            highlights = $(elem).find('.annotator-hl');
            assert.equal(highlights.length, 1);
            return assert.equal($(highlights[0]).attr('data-annotation-id'), 'elephants');
        });
        return it("should return the list of new highlight elements", function() {
            var highlights;
            ann.id = 'elephants';
            highlights = hl.redraw(ann);
            return assert.equal($(highlights[0]).attr('data-annotation-id'), 'elephants');
        });
    });
    describe('.drawAll(annotations)', function() {
        var anns;
        anns = null;
        beforeEach(function() {
            return anns = [
                {
                    id: 'abc123',
                    ranges: [
                        {
                            start: '/p[1]',
                            startOffset: 0,
                            end: '/p[1]',
                            endOffset: 12
                        }
                    ]
                }, {
                    id: 'def456',
                    ranges: [
                        {
                            start: '/p[2]',
                            startOffset: 0,
                            end: '/p[2]',
                            endOffset: 20
                        }
                    ]
                }
            ];
        });
        it("should draw highlights in the hl's element for each annotation in annotations", function() {
            var highlights;
            hl.drawAll(anns);
            highlights = $(elem).find('.annotator-hl');
            assert.equal(highlights.length, 2);
            assert.equal(highlights.eq(0).text(), 'Hello world!');
            return assert.equal(highlights.eq(1).text(), 'Giraffes like leaves');
        });
        it("should return a promise that resolves to the list of drawn highlights", function(done) {
            return hl.drawAll(anns).then(function(highlights) {
                assert.equal(highlights.length, 2);
                assert.equal($(highlights[0]).text(), 'Hello world!');
                return assert.equal($(highlights[1]).text(), 'Giraffes like leaves');
            }).then(done, done);
        });
        return it("should draw highlights in chunks of @options.chunkSize at a time, pausing for @options.chunkDelay between draws", function() {
            var annotations, clock;
            clock = sinon.useFakeTimers();
            sinon.stub(hl, 'draw');
            hl.options.chunkSize = 7;
            hl.options.chunkDelay = 42;
            annotations = [{}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}];
            hl.drawAll(annotations);
            assert.equal(hl.draw.callCount, 7);
            clock.tick(42);
            assert.equal(hl.draw.callCount, 13);
            clock.restore();
            return hl.draw.restore();
        });
    });
    describe('.destroy()', function() {
        return it("should remove any drawn highlights", function() {
            var ann;
            ann = {
                id: 'abc123',
                ranges: [
                    {
                        start: '/p[1]',
                        startOffset: 0,
                        end: '/p[1]',
                        endOffset: 12
                    }
                ]
            };
            hl.draw(ann);
            hl.destroy();
            return assert.equal($(elem).find('.annotator-hl').length, 0);
        });
    });
    // A helper function which returns a generated test case (a function)
    testFromData = function(event, i) {
        return function() {
            var actualHighlights, ann, annotations, expectedHighlights, _i, _len;
            annotations = testData[i].annotations;
            expectedHighlights = testData[i].highlights;
            // Draw the request annotations
            actualHighlights = [];
            for (_i = 0, _len = annotations.length; _i < _len; _i++) {
                ann = annotations[_i];
                actualHighlights = actualHighlights.concat(hl.draw(ann));
            }
            // First, a sanity check. Did we create the same number of highlights
            // as we expected.
            assert.equal(actualHighlights.length, expectedHighlights.length, "Didn't create the correct number of highlights");
            // Step through the created annotations, checking their textual
            // content against the values provided in testData.
            return expectedHighlights.forEach(function(hl, index) {
                var actualHl, annId, hlText;
                annId = hl[0], hlText = hl[1];
                actualHl = actualHighlights[index];
                // Check the highlight is a pointer to the right annotation
                assert.equal($(actualHl).data('annotation'), annotations[annId], "`annotation` data field doesn't point to correct annotation");
                // Check the highlight text is correct
                return assert.equal($(actualHl).text(), hlText);
            });
        };
    };
    _results = [];
    for (i = _i = 0, _ref = testData.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
        _results.push(it("should draw highlights correctly for test case " + i + " (" + testData[i].name + ")", testFromData('annotationCreated', i)));
    }
    return _results;
});
