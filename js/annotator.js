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
        var annotator = this;

        $.each(this.selectedRanges, function () {
            // FIXME: this currently won't DTRT if multiple ranges
            // share containers.
            var highlightedRange = annotator.highlightRange(this);    

            // TODO: append this.serializeRange(highlightedRange) to registry
        });

        this.ignoreMouseup = true;
        this.noteIcon.hide();
        return false;
    },
    
    // normaliseRange: this works around the fact that browsers don't generate 
    // ranges/selections in a consistent manner. Some (Safari) will create 
    // ranges that have (say) a TextNode startContainer and ElementNode 
    // endContainer. Others (Firefox) seem to only ever generate 
    // TextNode/TextNode or ElementNode/ElementNode pairs. 
    //
    // This will normalise any combination of the above into an object with
    // properties {s, so, e, eo} (for startContainer, startOffset, 
    // endContainer, endOffset respectively).
    normaliseRange: function (range) {
        var r = {
            s:  range.startContainer, 
            so: range.startOffset,
            e:  range.endContainer,
            eo: range.endOffset
        };

        $.each(['s', 'e'], function (idx, p) {
            var node = r[p], offset = r[p + 'o'];
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
            r[p + 'o'] = newOffset;
        });

        return r;
    },

    highlightRange: function (range) {
        var r = this.normaliseRange(range); 
        var towrap = []; 

        if (r.s !== r.e) {
            // textNodes() returns a jQuery object, so use flatten to turn it
            // into a plain ol' list.
            var towrap = $.flatten( $(range.commonAncestorContainer).textNodes() );
            
            towrap = towrap.slice(towrap.indexOf(r.s), towrap.indexOf(r.e) + 1);
            towrap.unshift(towrap.shift().splitText(r.so));
            towrap.slice(-1)[0].splitText(r.eo);
        } else {
            var selection = r.s.splitText(r.so);
            selection.splitText(r.eo - r.so);

            towrap.push(selection);
        }
        
        $.each(towrap, function () {
            $(this).wrap('<span class="highlight jsannotate"></span>');
        });

        return {
            s: towrap[0],
            e: towrap.slice(-1)[0]
        };
    },

    serializeRange: function (highlightRangeOutput) {
        var r = {};
        r.start = $(highlightRangeOutput.s.parentNode).xpath4jsannotate().get(0);
        r.end   = $(highlightRangeOutput.e.parentNode).xpath4jsannotate().get(0);

        // TODO: calculate real offsets, ignoring jsannotate-generated <spans>

        return r;
    }
});

