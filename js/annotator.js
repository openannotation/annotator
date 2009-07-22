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
        var span = $('<span class="hilight"></span>');
                
        this.selection = this.getSelection();
        
        if (this.selection.isCollapsed) {
            this.selection = null;
            this.anchor = null;
            this.focus = null;
        } else {
            this.anchor = [this.selection.anchorNode.parentNode, this.selection.anchorOffset];
            this.focus = [this.selection.focusNode.parentNode, this.selection.focusOffset];
        }
    },
    
    getSelection: function () {
        if (window.getSelection) {
            return window.getSelection();
        }
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

        if (this.selection) {
            this.noteLink = $('#noteLink').show().css({
                top: e.pageY - 25,
                left: e.pageX + 3
            });
        }
    },
    
    createNote: function (e) {
        this.ignoreMouseup = true;
        try {
            this.selection.getRangeAt(0).surroundContents($('<span class="hilight"></span>').get(0));  
        } catch(err) {
            $('#unable').fadeIn(500);
            setTimeout("$('#unable').fadeOut(500)", 2000);
        }
        this.noteLink.hide();
        return false;
    }
});