// Selection and range creation reference for the following code:
// http://www.quirksmode.org/dom/range_intro.html
//
// I've removed any support for IE TextRange (see commit d7085bf2 for code)
// for the moment, having no means of testing it.

var Annotator = DelegatorClass.extend({
    annotations: [
        // { id: 1,
        //   text: "My annotation",
        //   ranges: [
        //     { uri: "http://www.example.com/my/resource/identifier",
        //       start: "/html/body/div/p[2]",
        //       startOffset: 32,
        //       end: "/html/body/div/p[3]",
        //       endOffset: 47
        //     },
        //     { uri: "http://...", ... } 
        //   ]
        // },
    ],
    
    events: {
        'body mouseup': 'mouseup',
        '#noteIcon img mousedown': 'createAnnotation'
    },

    init: function () {
        this._super();
        this.noteIcon = $('#noteIcon');
    },

    mouseup: function (e) {
        // This prevents the note image from jumping away on the mouseup
        // of a click on icon.
        if (this.ignoreMouseup) {
            this.ignoreMouseup = false;
            return;
        }

        this.getSelection();

        if (this.validSelection()) {
            this.noteIcon.show().css({
                top: e.pageY - 25,
                left: e.pageX + 3
            });
        } else {
            this.noteIcon.hide();
        }
    },
    
    getSelection: function () {
        // TODO: fail gracefully in IE. 
        this.selection = window.getSelection(); 
        this.selectedRanges = [];
        for(var i = 0; i < this.selection.rangeCount; i += 1) {
            this.selectedRanges.push(this.selection.getRangeAt(i));
        }
    },

    validSelection: function () {
        return this.selection && 
               this.selection.rangeCount > 0 && 
              !this.selection.isCollapsed;
    },

    createAnnotation: function (e) {
        var annotator = this,
            annotation = this.register({});

        $.each(this.selectedRanges, function () {
            // FIXME: this currently won't DTRT if multiple ranges
            // share containers.
            var normedRange = annotator.normRange(this);    

            annotator.highlightRange(normedRange); 
            annotation.ranges.push(
                annotator.serializeRange(normedRange)
            );
        });

        this.ignoreMouseup = true;
        this.noteIcon.hide();
        return false;
    },

    register: function (annotation) {
        this.annotations.push(annotation);
        annotation.text = annotation.text || "";
        annotation.ranges = annotation.ranges || [];
        return annotation;
    },
    
    // normRange: works around the fact that browsers don't generate 
    // ranges/selections in a consistent manner. Some (Safari) will create 
    // ranges that have (say) a textNode startContainer and elementNode 
    // endContainer. Others (Firefox) seem to only ever generate 
    // textNode/textNode or elementNode/elementNode pairs. 
    //
    // This will return a (start, end, commonAncestor) triple, where start and 
    // end are textNodes, and commonAncestor is an elementNode.
    //
    // NB: This method may well split textnodes (i.e. alter the DOM) to 
    // achieve this.
    normRange: function (range) {
        var r = {
            start: range.startContainer,
            startOffset: range.startOffset,
            end: range.endContainer,
            endOffset: range.endOffset
        };

        $.each(['start', 'end'], function (idx, p) {
            var node = r[p], offset = r[p + 'Offset'];
            var newOffset = offset;

            if(node.nodeType === Node.ELEMENT_NODE) {
                while(node.nodeType !== Node.TEXT_NODE) { node = node.firstChild; }
                for(var i = 0; i < offset; i += 1) {
                    if (node.nextSibling) {
                       node = node.nextSibling;
                       newOffset = 0;
                    } else {
                       newOffset = node.nodeValue.length;
                       break;
                    } 
                }
            }

            r[p] = node;
            r[p + 'Offset'] = newOffset;
        });

        var start, end;
        
        if (r.start !== r.end) {
            start = r.start.splitText(r.startOffset);
            r.end.splitText(r.endOffset);
            end = r.end;
        } else {
            start = r.start.splitText(r.startOffset);
            start.splitText(r.endOffset - r.startOffset);
            end = start;
        }

        return {
            start: start, 
            end: end,
            commonAncestor: range.commonAncestorContainer
        };
    },

    highlightRange: function (normedRange) {
        var textNodes = $(normedRange.commonAncestor).textNodes();

        textNodes.slice(textNodes.index(normedRange.start), 
                        textNodes.index(normedRange.end) + 1)
                 .each(function () {
                      $(this).wrap('<span class="highlight jsannotate"></span>');
                  });
    },


    // serializeRange: takes a normedRange and turns it into a 
    // serializedRange, which is two pairs of (xpath, character offset), which 
    // can be easily stored in a database and loaded through 
    // #loadAnnotations/#deserializeRange.
    serializeRange: function (normedRange) {
        var serialization = function (node, isEnd) { var origParent = 
            $(node).parents(':not(.jsannotate)').eq(0),
                xpath = origParent.xpath().get(0),
                textNodes = origParent.textNodes(),
                
                // Calculate real offset as the combined length of all the 
                // preceding textNode siblings. We include the length of the 
                // node if it's the end node.
                offset = $.inject(textNodes.slice(0, textNodes.index(node)), 0,
                function (acc, tn) {
                    return acc + tn.nodeValue.length;
                });

            return isEnd ? [xpath, offset + node.nodeValue.length] : [xpath, offset];
        },

        start = serialization(normedRange.start),
        end   = serialization(normedRange.end, true);

        return {
            // XPath strings
            start: start[0],
            end: end[0],
            // Character offsets (integer)
            startOffset: start[1],
            endOffset: end[1]
        };
    },

    deserializeRange: function (serializedRange) {
        var nodeFromXPath = function (xpath) {
            return document.evaluate(xpath, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null)
                           .singleNodeValue;
        };

        var startAncestry = serializedRange.start.split("/"),
            endAncestry   = serializedRange.end.split("/"),
            common = [],
            range = {};

        // Crudely find a near common ancestor by walking down the XPath from 
        // the root until the segments no longer match.
        for (var ii = 0; ii < startAncestry.length; ii += 1) {
            if (startAncestry[ii] === endAncestry[ii]) {
                common.push(startAncestry[ii]);
            } else {
                break;
            }
        };

        range.commonAncestorContainer = nodeFromXPath(common.join("/"));

        // Unfortunately, we *can't* guarantee only one textNode per 
        // elementNode, so we have to walk along the element's textNodes until 
        // the combined length of the textNodes to that point exceeds or 
        // matches the value of the offset.
        $.each(['start', 'end'], function () {
            var which = this, length = 0;
            $(nodeFromXPath(serializedRange[this])).textNodes().each(function () {
                if (length + this.nodeValue.length >= serializedRange[which + 'Offset']) {
                    range[which + 'Container'] = this;
                    range[which + 'Offset'] = serializedRange[which + 'Offset'] - length;
                    return false;
                } else {
                    length += this.nodeValue.length;
                }
            });
        });
        
        console.log(range);
        return this.normRange(range);

    }
});


