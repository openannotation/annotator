var assert = require('assertive-chai').assert;

var h = require('../../helpers');

var textselector = require('../../../src/ui/textselector'),
    util = require('../../../src/util');

var $ = util.$;

describe('ui.textselector.TextSelector', function () {
    var elem = null,
        ts = null,
        selections = null;

    // Helper function to capture selections
    function onSelection(ranges, event) {
        selections.push({
            ranges: ranges,
            event: event
        });
    }

    beforeEach(function () {
        h.addFixture('adder');
        elem = h.fix();
        selections = [];
        ts = new textselector.TextSelector(elem, {
            onSelection: onSelection
        });
    });

    afterEach(function () {
        ts.destroy();
        h.clearFixtures();
    });

    describe('.captureDocumentSelection()', function () {
        beforeEach(function () {
            var mockSelection;
            mockSelection = new h.MockSelection(h.fix(), ['/div/p', 0, '/div/p', 1, 'Hello world!', '--']);
            sinon.stub(global, 'getSelection').returns(mockSelection);
        });

        afterEach(function () {
            global.getSelection.restore();
        });

        it("should capture and normalise the current document selections", function () {
            var ranges = ts.captureDocumentSelection();
            assert.equal(ranges.length, 1);
            assert.equal(ranges[0].text(), 'Hello world!');
            assert.equal(ranges[0].normalize(), ranges[0]);
        });
    });

    describe('onSelection event handler', function () {
        var mockOffset = null,
            mockSelection = null;

        beforeEach(function () {
            mockOffset = {
                top: 123,
                left: 456
            };
            mockSelection = new h.MockSelection(h.fix(), ['/div/p', 0, '/div/p', 1, 'Hello world!', '--']);
            sinon.stub(util, 'mousePosition').returns(mockOffset);
            sinon.stub(global, 'getSelection').returns(mockSelection);
        });

        afterEach(function () {
            util.mousePosition.restore();
            global.getSelection.restore();
        });

        it("should receive the selected ranges when a selection is made", function () {
            $(global.document.body).trigger('mouseup');
            assert.equal(selections.length, 1);
            var s = selections[0];
            assert.equal(s.ranges[0].text(), 'Hello world!');
        });

        it("should receive the triggering event object when a selection is made", function () {
            $(global.document.body).trigger('mouseup');
            assert.equal(selections.length, 1);
            var s = selections[0];
            assert.equal(s.event.type, 'mouseup');
        });

        it("should be called with empty ranges if an empty selection is made", function () {
            mockSelection.removeAllRanges();
            $(global.document.body).trigger('mouseup');
            assert.equal(selections.length, 1);
            assert.deepEqual(selections[0].ranges, []);
        });

        it("should be called with empty ranges if the selection is of an Annotator element", function () {
            // Set the selection to a div which has the 'annotator-adder' class set
            global.getSelection.restore();
            mockSelection = new h.MockSelection(h.fix(), ['/div/div/p', 0, '/div/div/p', 1, 'Part of the Annotator UI.', '--']);
            sinon.stub(global, 'getSelection').returns(mockSelection);
            $(global.document.body).trigger('mouseup');
            assert.equal(selections.length, 1);
            assert.deepEqual(selections[0].ranges, []);
        });
    });
});
