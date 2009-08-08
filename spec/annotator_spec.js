JSpec.describe('Annotator', function () {

    before(function () {
        a = new Annotator();

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
    });

    before_each(function () {
        a.ignoreMouseup = false;
        a.annotations = [];

        fix = element(fixture('fixtures/annotator.html'));

        testTNs = fix.textNodes().get();
        testRanges = rangeGen(testTNs);
        testSelection = function (ii) {
            return selectionGen(fix.get(0).parentNode, testRanges, ii);
        };
    });

    it('has no annotations when first loaded', function () {
        expect(a.annotations).to(be_empty);
    });
    
    it('checks to see if a selection has been made on mouseup', function () {
        stub(window, 'getSelection').and_return(testSelection(0));
        expect(a.selection).to(be_null);
        a.checkForSelection();
        expect(a.selection).to(eql, testSelection(0));
    });

    it('surrounds the selection with a highlight element when the annotate icon is clicked on', function () {
        stub(window, 'getSelection').and_return(testSelection(0));
        a.checkForSelection();
        a.createAnnotation();
        expect(fix).to(have_one, 'span.' + a.classPrefix + '-highlighter');
        expect(fix.find('span.' + a.classPrefix + '-highlighter').text()).to(eql, "habitant morbi");
    });

    it('adds a serialized description of the selection to its registry', function () {
        stub(window, 'getSelection').and_return(testSelection(0));
        a.checkForSelection();
        a.createAnnotation();
        expect(a.annotations).to(have_length, 1);
        expect(a.annotations[0].ranges).to(eql, [{
            start: "/div/p/strong",
            startOffset: 13,
            end: "/div/p/strong",
            endOffset: 27
        }]);
    });

    describe('#normRange', function () {
        $.each(testRanges, function (idx) {
            it('parses testRange ' + idx + ' (' + testRanges[idx][5] + ')', function () {
                // Ooh, hackery in extremis...
                idx = parseInt(this.currentSpec.description.split(" ")[2]);

                normedRange = a.normRange(testSelection(idx).getRangeAt(0));
                textNodes = $(normedRange.commonAncestor).textNodes();
                textNodes = textNodes.slice(textNodes.index(normedRange.start), 
                                            textNodes.index(normedRange.end) + 1).get();
                rangeText = $.inject(textNodes, "", function (acc, next) {
                    return acc += next.nodeValue;
                });
                expect(rangeText).to(eql, testRanges[idx][4]);
            });
        });
    });
});
// vim:fdm=marker:
