"use strict";

var Util = require('../util');

var $ = Util.$,
    _t = Util.gettext;

// Configuration options
var defaultOptions = {
    // Configurable function which accepts an array of tags and
    // returns a string which will be used to fill the tags input.
    stringifyTags: function (array) {
        return array.join(" ");
    },
    // Configurable function which accepts a string (the contents)
    // of the tags input as an argument, and returns an array of
    // tags.
    parseTags: function (string) {
        string = $.trim(string);
        var tags = [];

        if (string) {
            tags = string.split(/\s+/);
        }

        return tags;
    }
};

function createTagsPlugin(opts) {
    var options = $.extend(true, {}, defaultOptions, opts);

    return {
        createViewerField: configureViewer(options),
        createEditorField: configureEditor(options)
    };
}

function configureViewer() {
    // Annotator.Viewer callback function. Updates the annotation display
    // with tags
    // removes the field from the Viewer if there are no tags to display.
    //
    // field      - The Element to populate with tags.
    // annotation - An annotation object to be display.
    //
    // Examples
    //
    //   field = $('<div />')[0]
    //   plugin.updateField(field, {tags: ['apples']})
    //   field.innerHTML # => Returns
    //      '<span class="annotator-tag">apples</span>'
    //
    // Returns nothing.
    function updateViewer (field, annotation) {
        field = $(field);
        if (annotation.tags &&
            $.isArray(annotation.tags) &&
            annotation.tags.length) {
            field.addClass('annotator-tags').html(function () {
                return $.map(annotation.tags, function (tag) {
                    return '<span class="annotator-tag">' +
                        Util.escapeHtml(tag) +
                        '</span>';
                }).join(' ');
            });
        } else {
            field.remove();
        }
    }

    function createViewerField (v) {
        v.addField({
            load: updateViewer
        });
    }

    return createViewerField;
}


function configureEditor(options) {
    // The input element added to the Annotator.Editor wrapped in jQuery.
    // Cached to save having to recreate it everytime the editor is displayed.
    var field = null;
    var input = null;

    // Annotator.Editor callback function. Updates the @input field with the
    // tags attached to the provided annotation.
    //
    // field      - The tags field Element containing the input Element.
    // annotation - An annotation object to be edited.
    //
    // Examples
    //
    //   field = $('<li><input /></li>')[0]
    //   plugin.updateField(field, {tags: ['apples', 'oranges', 'cake']})
    //   field.value # => Returns 'apples oranges cake'
    //
    // Returns nothing.
    function updateField (field, annotation) {
        var value = '';
        if (annotation.tags) {
            value = options.stringifyTags(annotation.tags);
        }
        input.val(value);
    }

    // Annotator.Editor callback function. Updates the annotation field with the
    // data retrieved from the @input property.
    //
    // field      - The tags field Element containing the input Element.
    // annotation - An annotation object to be updated.
    //
    // Examples
    //
    //   annotation = {}
    //   field = $('<li><input value="cake chocolate cabbage" /></li>')[0]
    //
    //   plugin.setAnnotationTags(field, annotation)
    //   annotation.tags # => Returns ['cake', 'chocolate', 'cabbage']
    //
    // Returns nothing.
    function setAnnotationTags (field, annotation) {
        annotation.tags = options.parseTags(input.val());
    }

    function createEditorField (e) {
        field = e.addField({
            label: _t('Add some tags here') + '\u2026',
            load: updateField,
            submit: setAnnotationTags
        });

        input = $(field).find(':input');
    }

    return createEditorField;
}


exports.createTagsPlugin = createTagsPlugin;

