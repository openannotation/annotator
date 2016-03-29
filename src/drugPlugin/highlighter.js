"use strict";

var Range = require('xpath-range').Range;
var xpath = require('xpath-range').xpath;
var util = require('../util');
var $ = util.$;
var Promise = util.Promise;
var HttpStorage = require('./../storage').HttpStorage;
var annhost = config.annotator.host;

// highlightRange wraps the DOM Nodes within the provided range with a highlight
// element of the specified class and returns the highlight Elements.
//
// normedRange - A NormalizedRange to be highlighted.
// cssClass - A CSS class to use for the highlight (default: 'annotator-hl')
//
// Returns an array of highlight Elements.
function highlightRange(normedRange, cssClass) {
    if (typeof cssClass === 'undefined' || cssClass === null) {
        cssClass = 'annotator-hl';
    }
    var white = /^\s*$/;

    // Ignore text nodes that contain only whitespace characters. This prevents
    // spans being injected between elements that can only contain a restricted
    // subset of nodes such as table rows and lists. This does mean that there
    // may be the odd abandoned whitespace node in a paragraph that is skipped
    // but better than breaking table layouts.
    var nodes = normedRange.textNodes(),
        results = [];
    for (var i = 0, len = nodes.length; i < len; i++) {
        var node = nodes[i];
        if (!white.test(node.nodeValue)) {

            //skip text node that been highlighted yet
            if (node.parentNode.className != "annotator-hl"){
                var hl = global.document.createElement('span');
                hl.className = cssClass;
	            hl.id = 'annotator-hl';
                hl.setAttribute("name", "annotator-hl");
                node.parentNode.replaceChild(hl, node);
                hl.appendChild(node);
                results.push(hl);
            }
        }
    }
    //console.log(results);

    return results;
}


function highlightOA(annotation, cssClass, storage){
    console.log("[INFO] begin xpath fixing by OA selector");
    var oaSelector = annotation.target.selector;
    var prefix = oaSelector.prefix, suffix = oaSelector.suffix, exact = oaSelector.exact;
    try{
        var isFixed = false;
        var nodes = $("p:contains('" + exact + "')" );
        for (var n = 0, nlen = nodes.length; n < nlen; n++){
            var node = nodes[n];
            
            var fullTxt = node.textContent.replace(/\s/g, " ");
	        var re = new RegExp(exact,"g");
            var res;
            
	        while (res = re.exec(fullTxt)){
                var index = res["index"];
                var prefixSub, suffixSub;
                
                prefixSub = fullTxt.substring(0,index);
                suffixSub = fullTxt.substring(index + oaSelector.exact.length);
                
                var b0 = (prefixSub.length > 0 || suffixSub.length > 0); 
                var b1 = (prefixSub.indexOf(prefix) >= 0) || (prefix.indexOf(prefixSub) >= 0);
                var b2 = (suffixSub.indexOf(suffix) >= 0) || (suffix.indexOf(suffixSub) >= 0);

                // if (prefix.indexOf("Potent inhibitors of CYP2D6 may increase")>=0) {
                //     console.log(b1 + "|" + b2);
                //     console.log(node);
                //     console.log("oaSelector:" + prefix + "|" + suffix);
                //     console.log("node hasn't been found:" + prefixSub + "|" + suffixSub);
                //     //console.log(suffix.indexOf("40 mg twice daily with fluvox"));  
                // }
                
                if (b0 && b1 && b2) {
                    
                    console.log("oaSelector:" + prefix + "|" + suffix);
                    console.log("node been found:" + prefixSub + "|" + suffixSub);

                    isFixed = true;
                    var path = xpath.fromNode($(node), $(document))[0];
                    path = path.replace("/html[1]/body[1]","");
                    
                    if (annotation.ranges[0].start != path)
                        annotation.ranges[0].start = path;
                    if (annotation.ranges[0].end != path)
                        annotation.ranges[0].end = path;
                    if (annotation.ranges[0].startOffset != index)
                        annotation.ranges[0].startOffset = index;
                    if (annotation.ranges[0].endOffset != index + exact.length)
                        annotation.ranges[0].endOffset = index + exact.length;
                
                    storage.update(annotation);
                    //this.redraw(annotation);
                    console.log("[INFO] xpath fixing completed!");
                }
            }
        }
        if (!isFixed) {
            console.log("[WARN] xpath fixing failed, oa selecter doesn't matched in document!");
            console.log("oaSelector:" + prefix + "|" + exact + "|" + suffix + "|");
            storage.delete({id : annotation.id});
        }
    }
    catch(err){
        console.log(err);
    }
}


// reanchorRange will attempt to normalize a range, swallowing Range.RangeErrors
// for those ranges which are not reanchorable in the current document.
function reanchorRange(range, rootElement) {
    try {
        return Range.sniff(range).normalize(rootElement);
    } catch (e) {
        if (!(e instanceof Range.RangeError)) {
            // Oh Javascript, why you so crap? This will lose the traceback.
            throw(e);
        }
        // Otherwise, we simply swallow the error. Callers are responsible
        // for only trying to draw valid annotations.
        console.log("[ERROR] reanchor range failure!");
        console.log(range);
    }
    return null;
}


// Highlighter provides a simple way to draw highlighted <span> tags over
// annotated ranges within a document.
//
// element - The root Element on which to dereference annotation ranges and
//           draw highlights.
// options - An options Object containing configuration options for the plugin.
//           See `Highlighter.options` for available options.
//
var Highlighter = exports.Highlighter = function Highlighter(element, options) {
    this.element = element;
    this.options = $.extend(true, {}, Highlighter.options, options);
};
Highlighter.prototype.destroy = function () {
    $(this.element)
        .find("." + this.options.highlightClass)
        .each(function (_, el) {
            $(el).contents().insertBefore(el);
            $(el).remove();
        });
};

// Public: Draw highlights for all the given annotations
//
// annotations - An Array of annotation Objects for which to draw highlights.
//
// Returns nothing.
Highlighter.prototype.drawAll = function (annotations) {
    var self = this;

    //alert("[INFO] hlhighlighter drawAll called")

    var p = new Promise(function (resolve) {
        var highlights = [];

        function loader(annList) {
            if (typeof annList === 'undefined' || annList === null) {
                annList = [];
            }

            var now = annList.splice(0, self.options.chunkSize);
            for (var i = 0, len = now.length; i < len; i++) {
                highlights = highlights.concat(self.draw(now[i]));
            }

            // If there are more to do, do them after a delay
            if (annList.length > 0) {
                setTimeout(function () {
                    loader(annList);
                }, self.options.chunkDelay);
            } else {
                resolve(highlights);
            }
        }

        var clone = annotations.slice();
        loader(clone);
    });

    return p;
};

// Public: Draw highlights for the annotation.
//
// annotation - An annotation Object for which to draw highlights.
//
// Returns an Array of drawn highlight elements.
Highlighter.prototype.draw = function (annotation) {

    if (annotation.annotationType != "DrugMention")
        return null;

    var normedRanges = [];
    var oaAnnotations = [];

    for (var i = 0, ilen = annotation.ranges.length; i < ilen; i++) {
        var r = reanchorRange(annotation.ranges[i], this.element);
        if (r !== null) { // xpath reanchored by range
            normedRanges.push(r);
        } else { // use OA prefix suffix approach
            oaAnnotations.push(annotation);
        }
    }

    var hasLocal = (typeof annotation._local !== 'undefined' &&
    annotation._local !== null);
    if (!hasLocal) {
        annotation._local = {};
    }
    var hasHighlights = (typeof annotation._local.highlights !== 'undefined' &&
    annotation._local.highlights === null);
    if (!hasHighlights) {
        annotation._local.highlights = [];
    }

    // highlight by xpath range
    for (var j = 0, jlen = normedRanges.length; j < jlen; j++) {
        var normed = normedRanges[j];
        
        $.merge(
            annotation._local.highlights,
            highlightRange(normed, this.options.highlightClass)
        );
    }

    // fix xpath by OA prefix suffix selector
    if (oaAnnotations.length > 0){

        if (!storage){
	        var queryOptStr = '{"emulateHTTP":false,"emulateJSON":false,"headers":{},"prefix":"http://' + annhost + '/annotatorstore","urls":{"create":"/annotations","update":"/annotations/{id}","destroy":"/annotations/{id}","search":"/search"}}';
	        var queryOptions = JSON.parse(queryOptStr);
            var storage = new HttpStorage(queryOptions);
        }

        for (var m = 0, mlen = oaAnnotations.length; m < mlen; m++) {
            highlightOA(oaAnnotations[m], this.options.highlightClass, storage);
        }
    }

    // Save the annotation data on each highlighter element.
    $(annotation._local.highlights).data('annotation', annotation);

    // Add a data attribute for annotation id if the annotation has one
    if (typeof annotation.id !== 'undefined' && annotation.id !== null) {
        $(annotation._local.highlights)
            .attr('data-annotation-id', annotation.id);
    }

    return annotation._local.highlights;
};

// Public: Remove the drawn highlights for the given annotation.
//
// annotation - An annotation Object for which to purge highlights.
//
// Returns nothing.
Highlighter.prototype.undraw = function (annotation) {
    var hasHighlights = (typeof annotation._local !== 'undefined' &&
    annotation._local !== null &&
    typeof annotation._local.highlights !== 'undefined' &&
    annotation._local.highlights !== null);

    if (!hasHighlights) {
        return;
    }

    for (var i = 0, len = annotation._local.highlights.length; i < len; i++) {
        var h = annotation._local.highlights[i];
        if (h.parentNode !== null) {
            $(h).replaceWith(h.childNodes);
        }
    }
    delete annotation._local.highlights;
};

// Public: Redraw the highlights for the given annotation.
//
// annotation - An annotation Object for which to redraw highlights.
//
// Returns the list of newly-drawn highlights.
Highlighter.prototype.redraw = function (annotation) {
    this.undraw(annotation);
    return this.draw(annotation);
};

Highlighter.options = {
    // The CSS class to apply to drawn highlights
    highlightClass: 'annotator-hl',
    // Number of annotations to draw at once
    chunkSize: 200,
    // Time (in ms) to pause between drawing chunks of annotations
    chunkDelay: 1
};


// standalone is a module that uses the Highlighter to draw/undraw highlights
// automatically when annotations are created and removed.
exports.standalone = function standalone(element, options) {
    var widget = exports.Highlighter(element, options);

    return {
        destroy: function () { widget.destroy(); },
        annotationsLoaded: function (anns) { widget.drawAll(anns); },
        annotationCreated: function (ann) { widget.draw(ann); },
        annotationDeleted: function (ann) { widget.undraw(ann); },
        annotationUpdated: function (ann) { widget.redraw(ann); }
    };
};
