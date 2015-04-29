"use strict";

var util = require('../util');

var $ = util.$;
var _t = util.gettext;

var NS = 'annotator-filter';


// Public: Creates a new instance of the Filter.
//
// options - An Object literal of options.
//
// Returns a new instance of the Filter.
var Filter = exports.Filter = function Filter(options) {
    this.options = $.extend(true, {}, Filter.options, options);
    this.classes = $.extend(true, {}, Filter.classes);
    this.element = $(Filter.html.element).appendTo(this.options.appendTo);

    this.filter  = $(Filter.html.filter);
    this.filters = [];
    this.current  = 0;

    for (var i = 0, len = this.options.filters.length; i < len; i++) {
        var filter = this.options.filters[i];
        this.addFilter(filter);
    }

    this.updateHighlights();

    var filterInput = '.annotator-filter-property input',
        self = this;
    this.element
        .on("focus." + NS, filterInput, function (e) {
            self._onFilterFocus(e);
        })
        .on("blur." + NS, filterInput, function (e) {
            self._onFilterBlur(e);
        })
        .on("keyup." + NS, filterInput, function (e) {
            self._onFilterKeyup(e);
        })
        .on("click." + NS, '.annotator-filter-previous', function (e) {
            self._onPreviousClick(e);
        })
        .on("click." + NS, '.annotator-filter-next', function (e) {
            self._onNextClick(e);
        })
        .on("click." + NS, '.annotator-filter-clear', function (e) {
            self._onClearClick(e);
        });

    this._insertSpacer();

    if (this.options.addAnnotationFilter) {
        this.addFilter({label: _t('Annotation'), property: 'text'});
    }
};

// Public: remove the filter instance and unbind events.
//
// Returns nothing.
Filter.prototype.destroy = function () {
    var html = $('html'),
        currentMargin = parseInt(html.css('padding-top'), 10) || 0;
    html.css('padding-top', currentMargin - this.element.outerHeight());
    this.element.off("." + NS);
    this.element.remove();
};

// Adds margin to the current document to ensure that the annotation toolbar
// doesn't cover the page when not scrolled.
//
// Returns itself
Filter.prototype._insertSpacer = function () {
    var html = $('html'),
        currentMargin = parseInt(html.css('padding-top'), 10) || 0;
    html.css('padding-top', currentMargin + this.element.outerHeight());
    return this;
};

// Public: Adds a filter to the toolbar. The filter must have both a label
// and a property of an annotation object to filter on.
//
// options - An Object literal containing the filters options.
//           label      - A public facing String to represent the filter.
//           property   - An annotation property String to filter on.
//           isFiltered - A callback Function that recieves the field input
//                        value and the annotation property value. See
//                        this.options.isFiltered() for details.
//
// Examples
//
//   # Set up a filter to filter on the annotation.user property.
//   filter.addFilter({
//     label: User,
//     property: 'user'
//   })
//
// Returns itself to allow chaining.
Filter.prototype.addFilter = function (options) {
    var filter = $.extend({
        label: '',
        property: '',
        isFiltered: this.options.isFiltered
    }, options);

    // Skip if a filter for this property has been loaded.
    var hasFilterForProp = false;
    for (var i = 0, len = this.filters.length; i < len; i++) {
        var f = this.filters[i];
        if (f.property === filter.property) {
            hasFilterForProp = true;
            break;
        }
    }
    if (!hasFilterForProp) {
        filter.id = 'annotator-filter-' + filter.property;
        filter.annotations = [];
        filter.element = this.filter.clone().appendTo(this.element);
        filter.element.find('label')
            .html(filter.label)
            .attr('for', filter.id);
        filter.element.find('input')
            .attr({
                id: filter.id,
                placeholder: _t('Filter by ') + filter.label + '\u2026'
            });
        filter.element.find('button').hide();

        // Add the filter to the elements data store.
        filter.element.data('filter', filter);

        this.filters.push(filter);
    }

    return this;
};

// Public: Updates the filter.annotations property. Then updates the state
// of the elements in the DOM. Calls the filter.isFiltered() method to
// determine if the annotation should remain.
//
// filter - A filter Object from this.filters
//
// Examples
//
//   filter.updateFilter(myFilter)
//
// Returns itself for chaining
Filter.prototype.updateFilter = function (filter) {
    filter.annotations = [];

    this.updateHighlights();
    this.resetHighlights();
    var input = $.trim(filter.element.find('input').val());

    if (!input) {
        return;
    }

    var annotations = this.highlights.map(function () {
        return $(this).data('annotation');
    });
    annotations = $.makeArray(annotations);

    for (var i = 0, len = annotations.length; i < len; i++) {
        var annotation = annotations[i],
            property = annotation[filter.property];

        if (filter.isFiltered(input, property)) {
            filter.annotations.push(annotation);
        }
    }

    this.filterHighlights();
};

// Public: Updates the this.highlights property with the latest highlight
// elements in the DOM.
//
// Returns a jQuery collection of the highlight elements.
Filter.prototype.updateHighlights = function () {
    // Ignore any hidden highlights.
    this.highlights = $(this.options.filterElement)
        .find('.annotator-hl:visible');
    this.filtered = this.highlights.not(this.classes.hl.hide);
};

// Public: Runs through each of the filters and removes all highlights not
// currently in scope.
//
// Returns itself for chaining.
Filter.prototype.filterHighlights = function () {
    var activeFilters = $.grep(this.filters, function (filter) {
        return Boolean(filter.annotations.length);
    });

    var filtered = [];
    if (activeFilters.length > 0) {
        filtered = activeFilters[0].annotations;
    }
    if (activeFilters.length > 1) {
        // If there are more than one filter then only annotations matched in
        // every filter should remain.
        var annotations = [];

        $.each(activeFilters, function () {
            $.merge(annotations, this.annotations);
        });

        var uniques = [];
        filtered = [];
        $.each(annotations, function () {
            if ($.inArray(this, uniques) === -1) {
                uniques.push(this);
            } else {
                filtered.push(this);
            }
        });
    }

    var highlights = this.highlights;
    for (var i = 0, len = filtered.length; i < len; i++) {
        highlights = highlights.not(filtered[i]._local.highlights);
    }
    highlights.addClass(this.classes.hl.hide);
    this.filtered = this.highlights.not(this.classes.hl.hide);

    return this;
};

// Public: Removes hidden class from all annotations.
//
// Returns itself for chaining.
Filter.prototype.resetHighlights = function () {
    this.highlights.removeClass(this.classes.hl.hide);
    this.filtered = this.highlights;
    return this;
};

// Updates the filter field on focus.
//
// event - A focus Event object.
//
// Returns nothing
Filter.prototype._onFilterFocus = function (event) {
    var input = $(event.target);
    input.parent().addClass(this.classes.active);
    input.next('button').show();
};

// Updates the filter field on blur.
//
// event - A blur Event object.
//
// Returns nothing.
Filter.prototype._onFilterBlur = function (event) {
    if (!event.target.value) {
        var input = $(event.target);
        input.parent().removeClass(this.classes.active);
        input.next('button').hide();
    }
};

// Updates the filter based on the id of the filter element.
//
// event - A keyup Event
//
// Returns nothing.
Filter.prototype._onFilterKeyup = function (event) {
    var filter = $(event.target).parent().data('filter');
    if (filter) {
        this.updateFilter(filter);
    }
};

// Locates the next/previous highlighted element in this.highlights from the
// current one or goes to the very first/last element respectively.
//
// previous - If true finds the previously highlighted element.
//
// Returns itself.
Filter.prototype._findNextHighlight = function (previous) {
    if (this.highlights.length === 0) {
        return this;
    }

    var offset = -1,
        resetOffset = 0,
        operator = 'gt';

    if (previous) {
        offset = 0;
        resetOffset = -1;
        operator = 'lt';
    }

    var active = this.highlights.not('.' + this.classes.hl.hide),
        current = active.filter('.' + this.classes.hl.active);

    if (current.length === 0) {
        current = active.eq(offset);
    }

    var annotation = current.data('annotation');

    var index = active.index(current[0]),
        next = active.filter(":" + operator + "(" + index + ")")
            .not(annotation._local.highlights)
            .eq(resetOffset);

    if (next.length === 0) {
        next = active.eq(resetOffset);
    }

    this._scrollToHighlight(next.data('annotation')._local.highlights);
};

// Locates the next highlighted element in this.highlights from the current one
// or goes to the very first element.
//
// event - A click Event.
//
// Returns nothing
Filter.prototype._onNextClick = function () {
    this._findNextHighlight();
};

// Locates the previous highlighted element in this.highlights from the current
// one or goes to the very last element.
//
// event - A click Event.
//
// Returns nothing
Filter.prototype._onPreviousClick = function () {
    this._findNextHighlight(true);
};

// Scrolls to the highlight provided. An adds an active class to it.
//
// highlight - Either highlight Element or an Array of elements. This value
//             is usually retrieved from annotation._local.highlights.
//
// Returns nothing.
Filter.prototype._scrollToHighlight = function (highlight) {
    highlight = $(highlight);

    this.highlights.removeClass(this.classes.hl.active);
    highlight.addClass(this.classes.hl.active);

    $('html, body').animate({
        scrollTop: highlight.offset().top - (this.element.height() + 20)
    }, 150);
};

// Clears the relevant input when the clear button is clicked.
//
// event - A click Event object.
//
// Returns nothing.
Filter.prototype._onClearClick = function (event) {
    $(event.target).prev('input').val('').keyup().blur();
};

// Common classes used to change filter state.
Filter.classes = {
    active: 'annotator-filter-active',
    hl: {
        hide: 'annotator-hl-filtered',
        active: 'annotator-hl-active'
    }
};

// HTML templates for the filter UI.
Filter.html = {
    element: [
        '<div class="annotator-filter">',
        '  <strong>' + _t('Navigate:') + '</strong>',
        '  <span class="annotator-filter-navigation">',
        '    <button type="button"',
        '            class="annotator-filter-previous">' +
            _t('Previous') +
            '</button>',
        '    <button type="button"',
        '            class="annotator-filter-next">' + _t('Next') + '</button>',
        '  </span>',
        '  <strong>' + _t('Filter by:') + '</strong>',
        '</div>'
    ].join('\n'),

    filter: [
        '<span class="annotator-filter-property">',
        '  <label></label>',
        '  <input/>',
        '  <button type="button"',
        '          class="annotator-filter-clear">' + _t('Clear') + '</button>',
        '</span>'
    ].join('\n')
};

// Default options for Filter.
Filter.options = {
    // A CSS selector or Element to append the filter toolbar to.
    appendTo: 'body',

    // A CSS selector or Element to find and filter highlights in.
    filterElement: 'body',

    // An array of filters can be provided on initialisation.
    filters: [],

    // Adds a default filter on annotations.
    addAnnotationFilter: true,

    // Public: Determines if the property is contained within the provided
    // annotation property. Default is to split the string on spaces and only
    // return true if all keywords are contained in the string. This method
    // can be overridden by the user when initialising the filter.
    //
    // string   - An input String from the fitler.
    // property - The annotation propery to query.
    //
    // Examples
    //
    //   filter.option.getKeywords('hello', 'hello world how are you?')
    //   # => Returns true
    //
    //   plugin.option.getKeywords('hello bill', 'hello world how are you?')
    //   # => Returns false
    //
    // Returns an Array of keyword Strings.
    isFiltered: function (input, property) {
        if (!(input && property)) {
            return false;
        }

        var keywords = input.split(/\s+/);
        for (var i = 0, len = keywords.length; i < len; i++) {
            if (property.indexOf(keywords[i]) === -1) {
                return false;
            }
        }

        return true;
    }
};


// standalone is a module that uses the Filter component to display a filter bar
// to allow browsing and searching of annotations on the current page.
exports.standalone = function (options) {
    var widget = new exports.Filter(options);

    return {
        destroy: function () { widget.destroy(); },

        annotationsLoaded: function () { widget.updateHighlights(); },
        annotationCreated: function () { widget.updateHighlights(); },
        annotationUpdated: function () { widget.updateHighlights(); },
        annotationDeleted: function () { widget.updateHighlights(); }
    };
};
