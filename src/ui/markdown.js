/*package annotator.ui.markdown */
"use strict";

var util = require('../util');

var g = util.getGlobal();
var _t = util.gettext;


/**
 * function:: renderer(annotation)
 *
 * A renderer for the :class:`~annotator.ui.viewer.Viewer` which interprets
 * annotation text as `Markdown`_ and uses the `Showdown`_ library if present in
 * the page to render annotations with Markdown text as HTML.
 *
 * .. _Markdown: https://daringfireball.net/projects/markdown/
 * .. _Showdown: https://github.com/showdownjs/showdown
 *
 * **Usage**::
 *
 *     app.include(annotator.ui.main, {
 *         viewerRenderer: annotator.ui.markdown.renderer
 *     });
 */
exports.renderer = function renderer(annotation) {
    var convert = util.escapeHtml;

    if (g.Showdown && typeof g.Showdown.converter === 'function') {
        convert = new g.Showdown.converter().makeHtml;
    } else {
        console.warn(_t("To use the Markdown plugin, you must " +
                        "include Showdown into the page first."));
    }

    if (annotation.text) {
        return convert(annotation.text);
    } else {
        return "<i>" + _t('No comment') + "</i>";
    }
};
