var Range = require('xpath-range').Range;

var UI = require('../../../src/ui'),
    Util = require('../../../src/util');

var $ = Util.$;

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
        ranges: [{start: '/p[1]', startOffset: 0, end: '/p[1]', endOffset: 12}],
        highlights: ['Hello world!']
    },
    {
        name: 'single element subset',
        ranges: [{start: '/p[2]', startOffset: 9, end: '/p[2]', endOffset: 13}],
        highlights: ['like']
    },
    {
        name: 'spanning element boundaries',
        ranges: [{start: '/p[1]', startOffset: 6, end: '/p[2]', endOffset: 8}],
        highlights: ['world!', 'Giraffes']
    },
    {
        name: 'spanning multiple elements',
        ranges: [{start: '/p[1]', startOffset: 6, end: '/ul/li[1]', endOffset: 5}],
        highlights: ['world!', 'Giraffes like leaves.', 'First']
    },
    {
        name: 'multiple overlapping ranges',
        ranges: [
            {start: '/p[2]', startOffset: 0, end: '/p[2]', endOffset: 13},
            {start: '/p[2]', startOffset: 9, end: '/p[2]', endOffset: 21}
        ],
        highlights: ['Giraffes ', 'like', ' leaves.']
    },
    {
        name: 'multiple overlapping annotations spanning elements',
        ranges: [
            {start: '/p[1]', startOffset: 6, end: '/ul/li[1]', endOffset: 5},
            {start: '/ul[1]/li[1]', startOffset: 0, end: '/ul/li[2]', endOffset: 11}
        ],
        highlights: ['world!', 'Giraffes like leaves.', 'First', 'First', ' item', 'Second item']
    }
];

describe('UI.Highlighter', function () {
    var elem = null,
        hl = null;

    beforeEach(function () {
        elem = $(testDocument).get(0);
        hl = new UI.Highlighter(elem);
    });

    afterEach(function () {
        hl.destroy();
    });

    describe('.draw(ranges)', function () {
        var ranges = [{start: '/p[1]', startOffset: 0, end: '/p[1]', endOffset: 12}];

        afterEach(function () {
            if (typeof Range.sniff.restore === 'function') {
                Range.sniff.restore();
            }
        });

        it("should return drawn highlights", function () {
            var highlights = hl.draw(ranges);
            assert.equal(highlights.length, 1);
            assert.equal($(highlights[0]).text(), 'Hello world!');
        });

        it("should draw highlights in the hl's element", function () {
            hl.draw(ranges);
            var highlights = $(elem).find('.annotator-hl');
            assert.equal(highlights.length, 1);
            assert.equal(highlights.text(), 'Hello world!');
        });

        it("should swallow errors if the annotation fails to normalize", function () {
            var e = new Range.RangeError("typ", "RangeError should have been caught!");
            sinon.stub(Range, 'sniff').returns({
                normalize: sinon.stub().throws(e)
            });
            hl.draw([{fake: 'range'}]);
        });
    });

    describe('.undraw(highlights)', function () {
        var highlights = null;

        beforeEach(function () {
            highlights = hl.draw([
                {start: '/p[1]', startOffset: 0, end: '/p[1]', endOffset: 12}
            ]);
        });

        it("should remove the highlights from the document", function () {
            hl.undraw(highlights);
            var remaining = $(elem).find('.annotator-hl');
            assert.equal(remaining.length, 0);
        });
    });

    describe('.destroy()', function () {
        it("should remove any drawn highlights", function () {
            var ranges = [
                {start: '/p[1]', startOffset: 0, end: '/p[1]', endOffset: 12}
            ];
            hl.draw(ranges);
            hl.destroy();
            assert.equal($(elem).find('.annotator-hl').length, 0);
        });
    });

    // A helper function which returns a generated test case (a function)
    function testFromData(i) {
        return function () {
            var ranges = testData[i].ranges;
            var expectedHighlights = testData[i].highlights;

            // Draw the request annotations
            var actualHighlights = hl.draw(ranges);

            // First, a sanity check. Did we create the same number of highlights
            // as we expected.
            assert.equal(
                actualHighlights.length,
                expectedHighlights.length,
                "Didn't create the correct number of highlights"
            );

            // Step through the created highlights, checking their textual
            // content against the values provided in testData.
            expectedHighlights.forEach(function (hl, index) {
                var hlText = hl,
                    actualHl = actualHighlights[index];

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
