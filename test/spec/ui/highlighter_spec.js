var assert = require('assertive-chai').assert;

var Range = require('xpath-range').Range;

var highlighter = require('../../../src/ui/highlighter'),
    util = require('../../../src/util');

var $ = util.$;

var testDocument = [
    '<div>',
    '  <p>Hello world!</p>',
    '  <p>Giraffes like leaves.</p>',
    '  <ul>',
    '    <li>First item</li>',
    '    <li>Second item</li>',
    '  </ul>',
    '</div>'
].join('\n');

var testData = [
    {
        name: 'single element inner',
        annotations: [
            {ranges: [{start: '/p[1]', startOffset: 0, end: '/p[1]', endOffset: 12}]}
        ],
        highlights: [[0, 'Hello world!']]
    },
    {
        name: 'single element subset',
        annotations: [
            {ranges: [{start: '/p[2]', startOffset: 9, end: '/p[2]', endOffset: 13}]}
        ],
        highlights: [[0, 'like']]
    },
    {
        name: 'spanning element boundaries',
        annotations: [
            {ranges: [{start: '/p[1]', startOffset: 6, end: '/p[2]', endOffset: 8}]}
        ],
        highlights: [[0, 'world!'], [0, 'Giraffes']]
    },
    {
        name: 'spanning multiple elements',
        annotations: [
            {ranges: [{start: '/p[1]', startOffset: 6, end: '/ul/li[1]', endOffset: 5}]}
        ],
        highlights: [[0, 'world!'], [0, 'Giraffes like leaves.'], [0, 'First']]
    },
    {
        name: 'multiple overlapping annotations',
        annotations: [
            {ranges: [{start: '/p[2]', startOffset: 0, end: '/p[2]', endOffset: 13}]},
            {ranges: [{start: '/p[2]', startOffset: 9, end: '/p[2]', endOffset: 21}]}
        ],
        highlights: [[0, 'Giraffes like'], [1, 'like'], [1, ' leaves.']]
    },
    {
        name: 'multiple overlapping annotations spanning elements',
        annotations: [
            {ranges: [{start: '/p[1]', startOffset: 6, end: '/ul/li[1]', endOffset: 5}]},
            {ranges: [{start: '/ul[1]/li[1]', startOffset: 0, end: '/ul/li[2]', endOffset: 11}]}
        ],
        highlights: [[0, 'world!'], [0, 'Giraffes like leaves.'], [0, 'First'], [1, 'First'], [1, ' item'], [1, 'Second item']]
    }
];

describe('ui.highlighter.Highlighter', function () {
    var elem = null,
        hl = null;

    beforeEach(function () {
        elem = $(testDocument).get(0);
        hl = new highlighter.Highlighter(elem);
    });

    afterEach(function () {
        hl.destroy();
    });

    describe('.draw(annotation)', function () {
        var ann = null;

        beforeEach(function () {
            ann = {
                id: 'abc123',
                ranges: [{start: '/p[1]', startOffset: 0, end: '/p[1]', endOffset: 12}]
            };
        });

        afterEach(function () {
            if (typeof Range.sniff.restore === 'function') {
                Range.sniff.restore();
            }
        });

        it("should return drawn highlights", function () {
            var highlights = hl.draw(ann);
            assert.equal(highlights.length, 1);
            assert.equal($(highlights[0]).text(), 'Hello world!');
        });

        it("should draw highlights in the hl's element", function () {
            hl.draw(ann);
            var highlights = $(elem).find('.annotator-hl');
            assert.equal(highlights.length, 1);
            assert.equal(highlights.text(), 'Hello world!');
        });

        it("should set the `annotation` data property of each highlight element to be a reference to the annotation", function () {
            var highlights = hl.draw(ann);
            assert.equal(highlights.length, 1);
            assert.equal($(highlights[0]).data('annotation'), ann);
        });

        it("should set a `data-annotation-id` data attribute on each highlight with the annotations id, if it has one", function () {
            var highlights = hl.draw(ann);
            assert.equal(highlights.length, 1);
            assert.equal($(highlights[0]).attr('data-annotation-id'), ann.id);
        });

        it("should swallow errors if the annotation fails to normalize", function () {
            var e = new Range.RangeError("typ", "RangeError should have been caught!");
            sinon.stub(Range, 'sniff').returns({
                normalize: sinon.stub().throws(e)
            });
            hl.draw({
                id: 123,
                ranges: [{fake: 'range'}]
            });
        });
    });

    describe('.undraw(annotation)', function () {
        var ann = null;

        beforeEach(function () {
            ann = {
                id: 'abc123',
                ranges: [{start: '/p[1]', startOffset: 0, end: '/p[1]', endOffset: 12}]
            };
            hl.draw(ann);
        });

        it("should remove any highlights stored on the annotation", function () {
            hl.undraw(ann);
            var highlights = $(elem).find('.annotator-hl');
            assert.equal(highlights.length, 0);
        });
    });

    describe('.redraw(annotation)', function () {
        var ann = null;

        beforeEach(function () {
            ann = {
                id: 'abc123',
                ranges: [{start: '/p[1]', startOffset: 0, end: '/p[1]', endOffset: 12}]
            };
            hl.draw(ann);
        });

        it("should redraw any drawn highlights", function () {
            ann.id = 'elephants';
            hl.redraw(ann);
            var highlights = $(elem).find('.annotator-hl');
            assert.equal(highlights.length, 1);
            assert.equal($(highlights[0]).attr('data-annotation-id'), 'elephants');
        });

        it("should return the list of new highlight elements", function () {
            ann.id = 'elephants';
            var highlights = hl.redraw(ann);
            assert.equal($(highlights[0]).attr('data-annotation-id'), 'elephants');
        });
    });

    describe('.drawAll(annotations)', function () {
        var anns = null;

        beforeEach(function () {
            anns = [
                {
                    id: 'abc123',
                    ranges: [{start: '/p[1]', startOffset: 0, end: '/p[1]', endOffset: 12}]
                },
                {
                    id: 'def456',
                    ranges: [{start: '/p[2]', startOffset: 0, end: '/p[2]', endOffset: 20}]
                }
            ];
        });

        it("should draw highlights in the hl's element for each annotation in annotations", function () {
            hl.drawAll(anns);
            var highlights = $(elem).find('.annotator-hl');
            assert.equal(highlights.length, 2);
            assert.equal(highlights.eq(0).text(), 'Hello world!');
            assert.equal(highlights.eq(1).text(), 'Giraffes like leaves');
        });

        it("should return a promise that resolves to the list of drawn highlights", function (done) {
            hl.drawAll(anns)
                .then(function (highlights) {
                    assert.equal(highlights.length, 2);
                    assert.equal($(highlights[0]).text(), 'Hello world!');
                    assert.equal($(highlights[1]).text(), 'Giraffes like leaves');
                })
                .then(done, done);
        });

        it("should draw highlights in chunks of @options.chunkSize at a time, pausing for @options.chunkDelay between draws", function () {
            var clock = sinon.useFakeTimers();
            sinon.stub(hl, 'draw');
            hl.options.chunkSize = 7;
            hl.options.chunkDelay = 42;
            var annotations = [{}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}];
            hl.drawAll(annotations);
            assert.equal(hl.draw.callCount, 7);
            clock.tick(42);
            assert.equal(hl.draw.callCount, 13);
            clock.restore();
            hl.draw.restore();
        });
    });

    describe('.destroy()', function () {
        it("should remove any drawn highlights", function () {
            var ann = {
                id: 'abc123',
                ranges: [{start: '/p[1]', startOffset: 0, end: '/p[1]', endOffset: 12}]
            };
            hl.draw(ann);
            hl.destroy();
            assert.equal($(elem).find('.annotator-hl').length, 0);
        });
    });

    // A helper function which returns a generated test case (a function)
    function testFromData(i) {
        return function () {
            var annotations = testData[i].annotations;
            var expectedHighlights = testData[i].highlights;

            // Draw the request annotations
            var actualHighlights = [];
            for (var j = 0, len = annotations.length; j < len; j++) {
                var ann = annotations[j];
                actualHighlights = actualHighlights.concat(hl.draw(ann));
            }

            // First, a sanity check. Did we create the same number of highlights
            // as we expected.
            assert.equal(
                actualHighlights.length,
                expectedHighlights.length,
                "Didn't create the correct number of highlights"
            );

            // Step through the created annotations, checking their textual
            // content against the values provided in testData.
            expectedHighlights.forEach(function (hl, index) {
                var annId = hl[0],
                    hlText = hl[1],
                    actualHl = actualHighlights[index];

                // Check the highlight is a pointer to the right annotation
                assert.equal(
                    $(actualHl).data('annotation'),
                    annotations[annId],
                    "`annotation` data field doesn't point to correct annotation"
                );

                // Check the highlight text is correct
                assert.equal($(actualHl).text(), hlText);
            });
        };
    }

    for (var i = 0, len = testData.length; i < len; i++) {
        it(
            "should draw highlights correctly for test case " + i + " (" + testData[i].name + ")",
            testFromData(i)
        );
    }
});


describe('annotator.ui.highlighter.standalone', function () {
    var ann = null,
        mockElement = null,
        mockHighlighter = null,
        plugin = null,
        sandbox = null;

    beforeEach(function () {
        sandbox = sinon.sandbox.create();
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
        mockElement = {};
        mockHighlighter = {
            draw: sandbox.stub(),
            undraw: sandbox.stub(),
            redraw: sandbox.stub(),
            drawAll: sandbox.stub(),
            destroy: sandbox.stub()
        };

        sandbox.stub(highlighter, 'Highlighter').returns(mockHighlighter);

        plugin = highlighter.standalone(mockElement);
    });

    afterEach(function () {
        sandbox.restore();
    });

    it('should draw highlights annotationCreated', function () {
        plugin.annotationCreated(ann);
        sinon.assert.calledWith(mockHighlighter.draw, ann);
    });

    it('should redraw highlights annotationUpdated', function () {
        plugin.annotationUpdated(ann);
        sinon.assert.calledWith(mockHighlighter.redraw, ann);
    });

    it('should undraw highlights annotationDeleted', function () {
        plugin.annotationDeleted(ann);
        sinon.assert.calledWith(mockHighlighter.undraw, ann);
    });

    it('should draw all highlights annotationsLoaded', function () {
        var ann2 = {
            id: 'def456',
            ranges: [
                {
                    start: '/p[2]',
                    startOffset: 0,
                    end: '/p[2]',
                    endOffset: 20
                }
            ]
        };
        plugin.annotationsLoaded([ann, ann2]);
        sinon.assert.calledWith(mockHighlighter.drawAll, [ann, ann2]);
    });

    it('destroys the highlighter component when destroyed', function () {
        plugin.destroy();
        sinon.assert.calledOnce(mockHighlighter.destroy);
    });
});
