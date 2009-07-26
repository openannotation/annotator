require("spec_helper.js");
require("../js/jqext.js");
require("../js/annotator.js");

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
            sel = { getRangeAt: function (i) { return range; } };

        before(function () {
            a = new Annotator();
            stub(window, 'getSelection').and_return(sel);
        });
        
        it("checks to see if a selection has been made on mouseup", function() {
            expect(a.range).to(equal, null);
            $('body').mouseup();
            expect(a.range).to(equal, range);
        });

        it("highlights the selected text when the annotate icon is clicked on", function() {
            expect($(node.parentNode)).to(match_selector, "strong");
            expect(node.nodeValue.length).to(equal, 37);
            $('#noteLink img').mousedown();
            expect($(node.nextSibling)).to(match_selector, "span.hilight");
            expect(node.nodeValue.length).to(equal, 0);
        });
    });
});

