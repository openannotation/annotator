JSpec.describe('Annotator', function () {

    before(function () {
        rangeGen = function (x) {
            return [//{{{
                [ x[1], 13, x[1], 27, 
                 "habitant morbi",
                 "Partial node contents." ],
                [ x[1], 0, x[1], 37,
                 "Pellentesque habitant morbi tristique",
                 "Full node contents, textNode refs." ],
                [ x[1].parentNode, 0, x[1].parentNode, 1,
                 "Pellentesque habitant morbi tristique",
                 "Full node contents, elementNode refs." ],
                [ x[1], 22, x[2], 12, 
                 "morbi tristique senectus et",
                 "Spanning 2 nodes." ],
                [ x[1].parentNode, 0, x[2], 12, 
                 "Pellentesque habitant morbi tristique senectus et",
                 "Spanning 2 nodes, elementNode start ref." ],
                [ x[2], 165, x[3].parentNode, 1, 
                 "egestas semper. Aenean ultricies mi vitae est.",
                 "Spanning 2 nodes, elementNode end ref." ],
                [ x[10], 7, x[13], 11, 
                 "Level 2\n\n    \n      Lorem ipsum",
                 "Spanning multiple nodes, textNode refs." ],
                [ x[1].parentNode.parentNode, 0, x[1].parentNode.parentNode, 8, 
                 "Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Vestibulum tortor quam, feugiat vitae, ultricies eget, tempor sit amet, ante. Donec eu libero sit amet quam egestas semper. Aenean ultricies mi vitae est. Mauris placerat eleifend leo. Quisque sit amet est et sapien ullamcorper pharetra. Vestibulum erat wisi, condimentum sed, commodo vitae, ornare sit amet, wisi. Aenean fermentum, elit eget tincidunt condimentum, eros ipsum rutrum orci, sagittis tempus lacus enim ac dui. Donec non enim in turpis pulvinar facilisis. Ut felis.",
                 "Spanning multiple nodes, elementNode refs." ] 
            ];//}}}
        };

        selectionGen = function (commonAncestor, ranges, ii) {
            return {
                rangeCount: 1,
                isCollapsed: false,
                getRangeAt: function () {
                    return {
                        startContainer: ranges[ii][0],
                        startOffset:    ranges[ii][1],
                        endContainer:   ranges[ii][2],
                        endOffset:      ranges[ii][3],
                        commonAncestorContainer: commonAncestor
                    };
                }
            };
        };

        textInNormedRange = function (range) {
            textNodes = $(range.commonAncestor).textNodes();
            textNodes = textNodes.slice(textNodes.index(range.start), 
                                        textNodes.index(range.end) + 1).get();
            return $.inject(textNodes, "", function (acc, next) {
                return acc += next.nodeValue;
            });
        };
    });

    before_each(function () {
        fix = $(fixture('fixtures/annotator.html')).get(0).parentNode;

        a = new Annotator({}, fix);

        testTNs = $(fix).textNodes().get();
        testRanges = rangeGen(testTNs);
        testSelection = function (ii) {
            return selectionGen(fix, testRanges, ii);
        };
    });
    
    it('loads selections from the window object on checkForSelection', function () {
        stub(window, 'getSelection').and_return(testSelection(0));
        expect(a.selection).to(be_null);
        a.checkForSelection();
        expect(a.selection).to(eql, testSelection(0));
    });

    it('surrounds the window\'s selections with a highlight element on createAnnotation', function () {
        stub(window, 'getSelection').and_return(testSelection(0));
        a.checkForSelection();
        a.createAnnotation();
        expect($(fix).children()).to(have_one, 'span.annot-highlighter');
        expect($(fix).find('span.annot-highlighter').text()).to(eql, "habitant morbi");
    });

    it('can deserialize a serializedRange to a normedRange', function () {
        // XPath resolution won't work unless the fixture is actually in the 
        // document.
        $(fix).appendTo(document.body);

        deserialized = a.deserializeRange({
            start: "/p/strong",
            startOffset: 13,
            end: "/p/strong",
            endOffset: 27
        });

        // must reset fixture at this point.
        $(fix).remove();
        fix = $(fixture('fixtures/annotator.html')).get(0).parentNode;
        testTNs = $(fix).textNodes().get();
        testRanges = rangeGen(testTNs);
        testSelection = function (ii) {
            return selectionGen(fix, testRanges, ii);
        };

        normed = a.normRange(testSelection(0).getRangeAt(0));
        
        expect(textInNormedRange(deserialized)).to(eql, textInNormedRange(normed));
    });

    describe('#normRange', function () {
        $.each(testRanges, function (idx) {
            it('parses testRange ' + idx + ' (' + testRanges[idx][5] + ')', function () {
                // Ooh, hackery in extremis...
                idx = parseInt(this.currentSpec.description.split(" ")[2]);
                normedRange = a.normRange(testSelection(idx).getRangeAt(0));
                expect(textInNormedRange(normedRange)).to(eql, testRanges[idx][4]);
            });
        });
    });
});
// vim:fdm=marker:
