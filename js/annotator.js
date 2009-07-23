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
    
    init: function () {
        this._super();
        $.data(document.body, 'annotator', this);
    },
    
    update: function () {            
        // TODO: add support for multirange selections
        this.range = window.getSelection().getRangeAt(0);
        
        if (this.range.collapsed) { this.range = null; }
    },
    
    showNoteIcon: function (e) {
        this.update();
        
        // We seem to need to attach createNote to mouseDown, and this prevents
        // the note image from jumping away on the following mouseUp.
        if (this.ignoreMouseup) {
            this.ignoreMouseup = false;
            return;
        }

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
        this.hilight(); 
        this.noteLink.hide();
        return false;
    },
    
    hilight: function () {
        var r = this.range;
        var s = r.startContainer, e = r.endContainer,
            sOff = r.startOffset, eOff = r.endOffset;
            
        var hl = '<span class="hilight"></span>';
                        
        if (s !== e) {
            var towrap = $(r.commonAncestorContainer).textNodes();

            towrap = towrap.slice(towrap.indexOf(s), towrap.indexOf(e) + 1);
            towrap.unshift(towrap.shift().splitText(sOff));
            towrap.slice(-1)[0].splitText(eOff);

            $.each(towrap, function () {
                $(this).wrap(hl);
            });
        } else {
            if (s.nodeType === Node.ELEMENT_NODE) {
                $(s).wrapInner(hl);
            } else {
                var selection = s.splitText(sOff);
                selection.splitText(eOff - sOff);

                $(selection).wrap(hl);
            }   
        }
    }
});