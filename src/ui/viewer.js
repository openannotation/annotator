"use strict";

var Widget = require('./widget').Widget,
    util = require('../util');

var $ = util.$,
    _t = util.gettext;

var NS = 'annotator-viewer';


// Private: simple parser for hypermedia link structure
//
// Examples:
//
//   links = [
//     {
//       rel: 'alternate',
//       href: 'http://example.com/pages/14.json',
//       type: 'application/json'
//     },
//     {
//       rel: 'prev':
//       href: 'http://example.com/pages/13'
//     }
//   ]
//
//   parseLinks(links, 'alternate')
//   # => [{rel: 'alternate', href: 'http://...', ... }]
//   parseLinks(links, 'alternate', {type: 'text/html'})
//   # => []
//
function parseLinks(data, rel, cond) {
    cond = $.extend({}, cond, {rel: rel});

    var results = [];
    for (var i = 0, len = data.length; i < len; i++) {
        var d = data[i],
            match = true;

        for (var k in cond) {
            if (cond.hasOwnProperty(k) && d[k] !== cond[k]) {
                match = false;
                break;
            }
        }

        if (match) {
            results.push(d);
        }
    }

    return results;
}


// Public: Creates an element for viewing annotations.
var Viewer = exports.Viewer = Widget.extend({

    // Public: Creates an instance of the Viewer object.
    //
    // options - An Object containing options.
    //
    // Examples
    //
    //   # Creates a new viewer, adds a custom field and displays an annotation.
    //   viewer = new Viewer()
    //   viewer.addField({
    //     load: someLoadCallback
    //   })
    //   viewer.load(annotation)
    //
    // Returns a new Viewer instance.
    constructor: function (options) {
        Widget.call(this, options);

        this.itemTemplate = Viewer.itemTemplate;
        this.fields = [];
        this.annotations = [];
        this.hideTimer = null;
        this.hideTimerDfd = null;
        this.hideTimerActivity = null;
        this.mouseDown = false;
        this.render = function (annotation) {
            if (annotation.text) {
                return util.escapeHtml(annotation.text);
            } else {
                return "<i>" + _t('No comment') + "</i>";
            }
        };

        var self = this;

        if (this.options.defaultFields) {
            this.addField({
                load: function (field, annotation) {
                    $(field).html(self.render(annotation));
                }
            });
        }

        if (typeof this.options.onEdit !== 'function') {
            throw new TypeError("onEdit callback must be a function");
        }
        if (typeof this.options.onDelete !== 'function') {
            throw new TypeError("onDelete callback must be a function");
        }
        if (typeof this.options.permitEdit !== 'function') {
            throw new TypeError("permitEdit callback must be a function");
        }
        if (typeof this.options.permitDelete !== 'function') {
            throw new TypeError("permitDelete callback must be a function");
        }

        if (this.options.autoViewHighlights) {
            this.document = this.options.autoViewHighlights.ownerDocument;

            $(this.options.autoViewHighlights)
                .on("mouseover." + NS, '.annotator-hl', function (event) {
                    // If there are many overlapping highlights, still only
                    // call _onHighlightMouseover once.
                    if (event.target === this) {
                        self._onHighlightMouseover(event);
                    }
                })
                .on("mouseleave." + NS, '.annotator-hl', function () {
                    self._startHideTimer();
                });

            $(this.document.body)
                .on("mousedown." + NS, function (e) {
                    if (e.which === 1) {
                        self.mouseDown = true;
                    }
                })
                .on("mouseup." + NS, function (e) {
                    if (e.which === 1) {
                        self.mouseDown = false;
                    }
                });
        }

        this.element
            .on("click." + NS, '.annotator-edit', function (e) {
                self._onEditClick(e);
            })
            .on("click." + NS, '.annotator-delete', function (e) {
                self._onDeleteClick(e);
            })
            .on("mouseenter." + NS, function () {
                self._clearHideTimer();
            })
            .on("mouseleave." + NS, function () {
                self._startHideTimer();
            });
    },

    destroy: function () {
        if (this.options.autoViewHighlights) {
            $(this.options.autoViewHighlights).off("." + NS);
            $(this.document.body).off("." + NS);
        }
        this.element.off("." + NS);
        Widget.prototype.destroy.call(this);
    },

    // Public: Show the viewer.
    //
    // position - An Object specifying the position in which to show the editor
    //            (optional).
    //
    // Examples
    //
    //   viewer.show()
    //   viewer.hide()
    //   viewer.show({top: '100px', left: '80px'})
    //
    // Returns nothing.
    show: function (position) {
        if (typeof position !== 'undefined' && position !== null) {
            this.element.css({
                top: position.top,
                left: position.left
            });
        }

        var controls = this.element
            .find('.annotator-controls')
            .addClass(this.classes.showControls);

        var self = this;
        setTimeout(function () {
            controls.removeClass(self.classes.showControls);
        }, 500);

        Widget.prototype.show.call(this);
    },

    // Public: Load annotations into the viewer and show it.
    //
    // annotation - An Array of annotations.
    //
    // Examples
    //
    //   viewer.load([annotation1, annotation2, annotation3])
    //
    // Returns nothing.
    load: function (annotations, position) {
        this.annotations = annotations || [];

        var list = this.element.find('ul:first').empty();

        for (var i = 0, len = this.annotations.length; i < len; i++) {
            var annotation = this.annotations[i];
            this._annotationItem(annotation)
              .appendTo(list)
              .data('annotation', annotation);
        }

        this.show(position);
    },

    // Public: Set the annotation renderer.
    //
    // renderer - A function that accepts an annotation and returns HTML.
    //
    // Returns nothing.
    setRenderer: function (renderer) {
        this.render = renderer;
    },

    // Private: create the list item for a single annotation
    _annotationItem: function (annotation) {
        var item = $(this.itemTemplate).clone();

        var controls = item.find('.annotator-controls'),
            link = controls.find('.annotator-link'),
            edit = controls.find('.annotator-edit'),
            del  = controls.find('.annotator-delete');

        var links = parseLinks(
            annotation.links || [],
            'alternate',
            {'type': 'text/html'}
        );
        var hasValidLink = (links.length > 0 &&
                            typeof links[0].href !== 'undefined' &&
                            links[0].href !== null);

        if (hasValidLink) {
            link.attr('href', links[0].href);
        } else {
            link.remove();
        }

        var controller = {};
        if (this.options.permitEdit(annotation)) {
            controller.showEdit = function () {
                edit.removeAttr('disabled');
            };
            controller.hideEdit = function () {
                edit.attr('disabled', 'disabled');
            };
        } else {
            edit.remove();
        }
        if (this.options.permitDelete(annotation)) {
            controller.showDelete = function () {
                del.removeAttr('disabled');
            };
            controller.hideDelete = function () {
                del.attr('disabled', 'disabled');
            };
        } else {
            del.remove();
        }

        for (var i = 0, len = this.fields.length; i < len; i++) {
            var field = this.fields[i];
            var element = $(field.element).clone().appendTo(item)[0];
            field.load(element, annotation, controller);
        }

        return item;
    },

    // Public: Adds an addional field to an annotation view. A callback can be
    // provided to update the view on load.
    //
    // options - An options Object. Options are as follows:
    //           load - Callback Function called when the view is loaded with an
    //                  annotation. Recieves a newly created clone of an item
    //                  and the annotation to be displayed (it will be called
    //                  once for each annotation being loaded).
    //
    // Examples
    //
    //   # Display a user name.
    //   viewer.addField({
    //     # This is called when the viewer is loaded.
    //     load: (field, annotation) ->
    //       field = $(field)
    //
    //       if annotation.user
    //         field.text(annotation.user) # Display the user
    //       else
    //         field.remove()              # Do not display the field.
    //   })
    //
    // Returns itself.
    addField: function (options) {
        var field = $.extend({
            load: function () {}
        }, options);

        field.element = $('<div />')[0];
        this.fields.push(field);
        return this;
    },

    // Event callback: called when the edit button is clicked.
    //
    // event - An Event object.
    //
    // Returns nothing.
    _onEditClick: function (event) {
        var item = $(event.target)
            .parents('.annotator-annotation')
            .data('annotation');
        this.hide();
        this.options.onEdit(item);
    },

    // Event callback: called when the delete button is clicked.
    //
    // event - An Event object.
    //
    // Returns nothing.
    _onDeleteClick: function (event) {
        var item = $(event.target)
            .parents('.annotator-annotation')
            .data('annotation');
        this.hide();
        this.options.onDelete(item);
    },

    // Event callback: called when a user triggers `mouseover` on a highlight
    // element.
    //
    // event - An Event object.
    //
    // Returns nothing.
    _onHighlightMouseover: function (event) {
        // If the mouse button is currently depressed, we're probably trying to
        // make a selection, so we shouldn't show the viewer.
        if (this.mouseDown) {
            return;
        }

        var self = this;
        this._startHideTimer(true)
            .done(function () {
                var annotations = $(event.target)
                    .parents('.annotator-hl')
                    .addBack()
                    .map(function (_, elem) {
                        return $(elem).data("annotation");
                    })
                    .toArray();

                // Now show the viewer with the wanted annotations
                self.load(annotations, util.mousePosition(event));
            });
    },

    // Starts the hide timer. This returns a promise that is resolved when the
    // viewer has been hidden. If the viewer is already hidden, the promise will
    // be resolved instantly.
    //
    // activity - A boolean indicating whether the need to hide is due to a user
    //            actively indicating a desire to view another annotation (as
    //            opposed to merely mousing off the current one). Default: false
    //
    // Returns a Promise.
    _startHideTimer: function (activity) {
        if (typeof activity === 'undefined' || activity === null) {
            activity = false;
        }

        // If timer has already been set, use that one.
        if (this.hideTimer) {
            if (activity === false || this.hideTimerActivity === activity) {
                return this.hideTimerDfd;
            } else {
                // The pending timeout is an inactivity timeout, so likely to be
                // too slow. Clear the pending timeout and start a new (shorter)
                // one!
                this._clearHideTimer();
            }
        }

        var timeout;
        if (activity) {
            timeout = this.options.activityDelay;
        } else {
            timeout = this.options.inactivityDelay;
        }

        this.hideTimerDfd = $.Deferred();

        if (!this.isShown()) {
            this.hideTimer = null;
            this.hideTimerDfd.resolve();
            this.hideTimerActivity = null;
        } else {
            var self = this;
            this.hideTimer = setTimeout(function () {
                self.hide();
                self.hideTimerDfd.resolve();
                self.hideTimer = null;
            }, timeout);
            this.hideTimerActivity = Boolean(activity);
        }

        return this.hideTimerDfd.promise();
    },

    // Clears the hide timer. Also rejects any promise returned by a previous
    // call to _startHideTimer.
    //
    // Returns nothing.
    _clearHideTimer: function () {
        clearTimeout(this.hideTimer);
        this.hideTimer = null;
        this.hideTimerDfd.reject();
        this.hideTimerActivity = null;
    }
});

// Classes for toggling annotator state.
Viewer.classes = {
    showControls: 'annotator-visible'
};

// HTML templates for this.widget and this.item properties.
Viewer.template = [
    '<div class="annotator-outer annotator-viewer annotator-hide">',
    '  <ul class="annotator-widget annotator-listing"></ul>',
    '</div>'
].join('\n');

Viewer.itemTemplate = [
    '<li class="annotator-annotation annotator-item">',
    '  <span class="annotator-controls">',
    '    <a href="#"',
    '       title="' + _t('View as webpage') + '"',
    '       class="annotator-link">' + _t('View as webpage') + '</a>',
    '    <button type="button"',
    '            title="' + _t('Edit') + '"',
    '            class="annotator-edit">' + _t('Edit') + '</button>',
    '    <button type="button"',
    '            title="' + _t('Delete') + '"',
    '            class="annotator-delete">' + _t('Delete') + '</button>',
    '  </span>',
    '</li>'
].join('\n');

// Configuration options
Viewer.options = {
    // Add the default field(s) to the viewer.
    defaultFields: true,

    // Time, in milliseconds, before the viewer is hidden when a user mouses off
    // the viewer.
    inactivityDelay: 500,

    // Time, in milliseconds, before the viewer is updated when a user mouses
    // over another annotation.
    activityDelay: 100,

    // Hook, passed an annotation, which determines if the viewer's "edit"
    // button is shown. If it is not a function, the button will not be shown.
    permitEdit: function () { return false; },

    // Hook, passed an annotation, which determines if the viewer's "delete"
    // button is shown. If it is not a function, the button will not be shown.
    permitDelete: function () { return false; },

    // If set to a DOM Element, will set up the viewer to automatically display
    // when the user hovers over Annotator highlights within that element.
    autoViewHighlights: null,

    // Callback, called when the user clicks the edit button for an annotation.
    onEdit: function () {},

    // Callback, called when the user clicks the delete button for an
    // annotation.
    onDelete: function () {}
};


// standalone is a module that uses the Viewer to display an viewer widget in
// response to some viewer action (such as mousing over an annotator highlight
// element).
exports.standalone = function standalone(options) {
    var widget;

    if (typeof options === 'undefined' || options === null) {
        options = {};
    }

    return {
        start: function (app) {
            var ident = app.registry.getUtility('identityPolicy');
            var authz = app.registry.getUtility('authorizationPolicy');

            // Set default handlers for what happens when the user clicks the
            // edit and delete buttons:
            if (typeof options.onEdit === 'undefined') {
                options.onEdit = function (annotation) {
                    app.annotations.update(annotation);
                };
            }
            if (typeof options.onDelete === 'undefined') {
                options.onDelete = function (annotation) {
                    app.annotations['delete'](annotation);
                };
            }

            // Set default handlers that determine whether the edit and delete
            // buttons are shown in the viewer:
            if (typeof options.permitEdit === 'undefined') {
                options.permitEdit = function (annotation) {
                    return authz.permits('update', annotation, ident.who());
                };
            }
            if (typeof options.permitDelete === 'undefined') {
                options.permitDelete = function (annotation) {
                    return authz.permits('delete', annotation, ident.who());
                };
            }

            widget = new exports.Viewer(options);
        },

        destroy: function () { widget.destroy(); }
    };
};
