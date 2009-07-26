// Selection and range creation reference for the following code:
// http://www.quirksmode.org/dom/range_intro.html
//
// I've removed any support for IE TextRange (see commit d7085bf2 for code)
// for the moment, having no means of testing it.

var Annotator = DelegatorClass.extend({
    events: {
        'body mouseup': 'showNoteIcon',
        '#noteLink img mousedown': 'createNote'
    },
    
    update: function () {            
        // TODO: add support for multirange selections
        this.range = window.getSelection().getRangeAt(0);
        
        if (this.range.collapsed) { this.range = null; }
    },
    
    showNoteIcon: function (e) {
        // We seem to need to attach createNote to mouseDown, and this prevents
        // the note image from jumping away on the following mouseUp.
        if (this.ignoreMouseup) {
            this.ignoreMouseup = false;
            return;
        }

        this.update();

        if (this.noteLink) { this.noteLink.hide(); }

        if (this.range) {
            this.noteLink = $('#noteLink').show().css({
                top: e.pageY - 25,
                left: e.pageX + 3
            });
        }
    },
    
    createNote: function (e) {
        this.ignoreMouseup = true;
        this.hilightRange(this.range); 
        this.noteLink.hide();
        return false;
    },
    
    hilightRange: function (range) {
        var r = {
            s:  range.startContainer, 
            e:  range.endContainer,
            so: range.startOffset,
            eo: range.endOffset
        };
            
        var hl = '<span class="hilight"></span>';

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
                       newOffset = node.textContent.length;
                       break;
                    } 
                }
            }

            r[p] = node;
            r[p + 'o'] = newOffset;
        });

        if (r.s !== r.e) {
            // textNodes() returns a jQuery object, so use flatten to turn it
            // into a plain ol' list.
            var towrap = $.flatten( $(range.commonAncestorContainer).textNodes() );
            
            towrap = towrap.slice(towrap.indexOf(r.s), towrap.indexOf(r.e) + 1);
            towrap.unshift(towrap.shift().splitText(r.so));
            towrap.slice(-1)[0].splitText(r.eo);

            $.each(towrap, function () {
                $(this).wrap(hl);
            });
        } else {
            var selection = r.s.splitText(r.so);
            selection.splitText(r.eo - r.so);

            $(selection).wrap(hl);
        }
    }
});

