/*package annotator.ui.markdown */
"use strict";

var util = require('../util');

var _t = util.gettext;


/**
 * function:: render(annotation)
 *
 * Render an annotation to HTML, converting annotation text from Markdown if
 * Showdown is available in the page.
 *
 * :returns: Rendered HTML.
 * :rtype: String
 */
var render = exports.render = function render(annotation) {
    var convert = util.escapeHtml;

    if (global.showdown && typeof global.showdown.Converter === 'function') {
        convert = new global.showdown.Converter().makeHtml;
    }

    if (annotation.text) {
        return convert(annotation.text);
    } else {
        return "<i>" + _t('No comment') + "</i>";
    }
};


/**
 * function:: viewerExtension(viewer)
 *
 * An extension for the :class:`~annotator.ui.viewer.Viewer`. Allows the viewer
 * to interpret annotation text as `Markdown`_ and uses the `Showdown`_ library
 * if present in the page to render annotations with Markdown text as HTML.
 *
 * .. _Markdown: https://daringfireball.net/projects/markdown/
 * .. _Showdown: https://github.com/showdownjs/showdown
 *
 * **Usage**::
 *
 *     app.include(annotator.ui.main, {
 *         viewerExtensions: [annotator.ui.markdown.viewerExtension]
 *     });
 */
exports.viewerExtension = function viewerExtension(viewer) {
    if (!global.showdown || typeof global.showdown.Converter !== 'function') {
        console.warn(_t("To use the Markdown plugin, you must " +
                        "include Showdown into the page first."));
    }

    viewer.setRenderer(render);
};
