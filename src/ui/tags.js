"use strict";

var Util = require('../util');

var $ = Util.$,
    _t = Util.gettext;


function Tags(options) {
    var self = this;

    this.options = $.extend(true, {}, Tags.options, options);

    // The input element added to the Annotator.Editor wrapped in jQuery.
    // Cached to save having to recreate it everytime the editor is displayed.
    this.field = null;
    this.input = null;

    this.configureViewer = function (v) {
        v.addField({
            load: self.updateViewer
        });
    };

    this.configureEditor = function (e) {
        self.field = e.addField({
            label: _t('Add some tags here') + '\u2026',
            load: self.updateField,
            submit: self.setAnnotationTags
        });

        self.input = $(self.field).find(':input');
    };
}

// Public: Extracts tags from the provided String.
//
// string - A String of tags seperated by spaces.
//
// Examples
//
//   plugin.parseTags('cake chocolate cabbage')
//   # => ['cake', 'chocolate', 'cabbage']
//
// Returns Array of parsed tags.
Tags.prototype.parseTags = function (string) {
    return this.options.parseTags(string);
};

// Public: Takes an array of tags and serialises them into a String.
//
// array - An Array of tags.
//
// Examples
//
//   plugin.stringifyTags(['cake', 'chocolate', 'cabbage'])
//   # => 'cake chocolate cabbage'
//
// Returns Array of parsed tags.
Tags.prototype.stringifyTags = function (array) {
    return this.options.stringifyTags(array);
};

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
Tags.prototype.updateField = function (field, annotation) {
    var value = '';
    if (annotation.tags) {
        value = this.stringifyTags(annotation.tags);
    }

    this.input.val(value);
};

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
Tags.prototype.setAnnotationTags = function (field, annotation) {
    annotation.tags = this.parseTags(this.input.val());
};

// Annotator.Viewer callback function. Updates the annotation display with tags
// removes the field from the Viewer if there are no tags to display.
//
// field      - The Element to populate with tags.
// annotation - An annotation object to be display.
//
// Examples
//
//   field = $('<div />')[0]
//   plugin.updateField(field, {tags: ['apples']})
//   field.innerHTML # => Returns '<span class="annotator-tag">apples</span>'
//
// Returns nothing.
Tags.prototype.updateViewer = function (field, annotation) {
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
};

// Configuration options
Tags.options = {
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


exports.Tags = Tags;

