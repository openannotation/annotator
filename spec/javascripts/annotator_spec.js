require("spec_helper.js");
require("../../js/jqext.js");
require("../../js/annotator.js");

Screw.Unit(function() {
    describe("Annotator object", function() {
        var a,
            node = $('p').textNodes().get(0), 
            range = {
                startContainer: node,
                startOffset: 0,
                endContainer: node,
                endOffset: 27
            },
            sel = { 
                rangeCount: 1,
                isCollapsed: false,
                getRangeAt: function (i) { return range; }
            };

        before(function () {
            a = new Annotator();
            stub(window, 'getSelection').and_return(sel);
        });

        it("has no annotations when first loaded", function () {
            expect(a.annotations.length).to(equal, 0);
        });

        it("checks to see if a selection has been made on mouseup", function() {
            expect(a.selection).to(equal, null);
            $('body').mouseup();
            expect(a.selection).to(equal, sel);
            expect(a.validSelection()).to(equal, true);
        });

        it("highlights the selected text when the annotate icon is clicked on", function() {
            expect($(node.parentNode)).to(match_selector, "strong");
            expect(node.nodeValue.length).to(equal, 37);
            $('body').mouseup();
            $('#noteIcon img').mousedown();
            expect($(node.nextSibling)).to(match_selector, "span.highlight");
            expect(node.nodeValue.length).to(equal, 0);
        });

        it("adds a description of the selection to its registry", function () {
            expect(a.annotations.length).to(equal, 1);
            expect(a.annotations[0].ranges).to(equal, [{
                start: "/html/body/div/p/strong",
                startOffset: 0,
                end: "/html/body/div/p/strong",
                endOffset: 27
            }]);
        });
    });
});

