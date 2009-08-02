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

        this.loadSelection();

        if (this.validSelection()) {
            this.noteIcon.show().css({
                top: e.pageY - 25,
                left: e.pageX + 3
            });
        } else {
            this.noteIcon.hide();
        }
    },
    
    loadSelection: function () {
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
            var newRange = annotator.highlightRange(this);    
             
            annotation.ranges.push(
                annotator.serializeRange(newRange.start, newRange.end)
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
    
    // normaliseRange: this works around the fact that browsers don't generate 
    // ranges/selections in a consistent manner. Some (Safari) will create 
    // ranges that have (say) a TextNode startContainer and ElementNode 
    // endContainer. Others (Firefox) seem to only ever generate 
    // TextNode/TextNode or ElementNode/ElementNode pairs. 
    normaliseRange: function (range) {
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

        return r;
    },

    highlightRange: function (range) {
        var r = this.normaliseRange(range); 
        var towrap = []; 

        if (r.start !== r.end) {
            var towrap = $(range.commonAncestorContainer).textNodes().get();
            
            towrap = towrap.slice(towrap.indexOf(r.start), towrap.indexOf(r.end) + 1);
            towrap.unshift(towrap.shift().splitText(r.startOffset));
            towrap.slice(-1)[0].splitText(r.endOffset);
        } else {
            var selection = r.start.splitText(r.startOffset);
            selection.splitText(r.endOffset - r.startOffset);

            towrap.push(selection);
        }
        
        $.each(towrap, function () {
            $(this).wrap('<span class="highlight jsannotate"></span>');
        });

        return {
            start: towrap[0],
            end: towrap.slice(-1)[0]
        };
    },

    serializeRange: function (start, end) {
        var serialization = function (node, isEnd) { 
            var origParent = $(node).parents(':not(.jsannotate)').eq(0),
                xpath = origParent.xpath().get(0),
                textNodes = origParent.textNodes(),
                //
                // Calculate real offset as the combined length of all the 
                // preceding textNode siblings. We include the length of the 
                // node if it's the end node.
                offset = $.inject(textNodes.slice(0, textNodes.index(node)), 0,
                function (acc, tn) {
                    return acc + tn.nodeValue.length;
                });

            return isEnd ? [xpath, offset + node.nodeValue.length] : [xpath, offset];
        },

        start = serialization(start),
        end   = serialization(end, true);

        return {
            start: start[0],
            startOffset: start[1],
            end: end[0],
            endOffset: end[1]
        };
    }
});


