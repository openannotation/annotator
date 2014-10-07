var $, Annotator;

window._annotatorConfig = {
    test: true,
    target: "#fixtures",
    externals: {
        source: "../notexist/annotator.js",
        styles: "../notexist/annotator.css"
    },
    auth: {
        autoFetch: false
    },
    tags: true,
    store: {
        prefix: ""
    },
    annotateItPermissions: {
        showViewPermissionsCheckbox: true,
        showEditPermissionsCheckbox: true,
        user: {
            id: "Aron",
            name: "Aron"
        },
        permissions: {
            read: ["Aron"],
            update: ["Aron"],
            "delete": ["Aron"],
            admin: ["Aron"]
        }
    }
};

Annotator = require('annotator');

$ = require('../../src/util').$;

require('../../src/bootstrap');

describe("bookmarklet", function() {
    var body, bookmarklet, head;
    bookmarklet = null;
    head = document.getElementsByTagName('head')[0];
    body = document.body;
    beforeEach(function() {
        window.Annotator = Annotator;
        bookmarklet = window._annotator.bookmarklet;
        // Prevent Notifications from being fired
        sinon.stub(bookmarklet.notification, "show");
        sinon.stub(bookmarklet.notification, "message");
        sinon.stub(bookmarklet.notification, "hide");
        sinon.stub(bookmarklet.notification, "remove");
        sinon.spy(bookmarklet, "config");
        return sinon.stub(bookmarklet, "_injectElement", function(where, el) {
            if (el.onload != null) {
                return el.onload.call();
            }
        });
    });
    afterEach(function() {
        var error;
        try {
            delete window.Annotator;
        } catch (_error) {
            error = _error;
            window.Annotator = void 0;
        }
        bookmarklet.notification.show.restore();
        bookmarklet.notification.message.restore();
        bookmarklet.notification.hide.restore();
        bookmarklet.notification.remove.restore();
        bookmarklet.config.restore();
        bookmarklet._injectElement.restore();
        return $(".annotator-bm-status, .annotator-notice").remove();
    });
    describe("init()", function() {
        beforeEach(function() {
            return sinon.spy(bookmarklet, "load");
        });
        afterEach(function() {
            return bookmarklet.load.restore();
        });
        it("should display a notification telling the user the page is loading", function() {
            bookmarklet.init();
            return assert(bookmarklet.notification.show.called);
        });
        return it("should display a notification if the bookmarklet has loaded", function() {
            window._annotator.instance = {};
            window._annotator.Annotator = {
                showNotification: sinon.spy()
            };
            bookmarklet.init();
            return assert(window._annotator.Annotator.showNotification.called);
        });
    });
    describe("load()", function() {
        it("should append the stylesheet to the head", function(done) {
            return bookmarklet.load(function() {
                assert(bookmarklet._injectElement.calledWith('head'));
                return done();
            });
        });
        return it("should append the script to the body", function(done) {
            return bookmarklet.load(function() {
                assert(bookmarklet._injectElement.calledWith('body'));
                return done();
            });
        });
    });
    describe("setup()", function() {
        var hasPlugin;
        hasPlugin = function(instance, name) {
            return name in instance.plugins;
        };
        beforeEach(function() {
            return bookmarklet.setup();
        });
        it("should export useful values to window._annotator", function() {
            assert.isFunction(window._annotator.Annotator);
            assert.isObject(window._annotator.instance);
            assert.isFunction(window._annotator.jQuery);
            return assert.isObject(window._annotator.element);
        });
        it("should add the plugins to the annotator instance", function() {
            var instance;
            instance = window._annotator.instance;
            assert(hasPlugin(instance, 'Auth'));
            assert(hasPlugin(instance, 'Store'));
            assert(hasPlugin(instance, 'AnnotateItPermissions'));
            return assert(hasPlugin(instance, 'Unsupported'));
        });
        it("should add the tags plugin if options.tags is true", function() {
            var instance;
            instance = window._annotator.instance;
            return assert(hasPlugin(instance, 'Tags'));
        });
        return it("should display a loaded notification", function() {
            return assert(bookmarklet.notification.message.called);
        });
    });
    describe("annotateItPermissionsOptions()", function() {
        it("should return an object literal", function() {
            return assert.isObject(bookmarklet.annotateItPermissionsOptions());
        });
        return it("should retrieve user and permissions from config", function() {
            bookmarklet.annotateItPermissionsOptions();
            return assert(bookmarklet.config.calledWith("annotateItPermissions"));
        });
    });
    return describe("storeOptions()", function() {
        it("should return an object literal", function() {
            return assert.isObject(bookmarklet.storeOptions());
        });
        it("should retrieve store prefix from config", function() {
            bookmarklet.storeOptions();
            return assert(bookmarklet.config.calledWith("store.prefix"));
        });
        return it("should have set a uri property", function() {
            var uri;
            uri = bookmarklet.storeOptions().annotationData.uri;
            return assert(uri);
        });
    });
});

describe("bookmarklet.notification", function() {
    var bookmarklet, notification;
    bookmarklet = null;
    notification = void 0;
    beforeEach(function() {
        bookmarklet = window._annotator.bookmarklet;
        notification = bookmarklet.notification;
        sinon.spy(bookmarklet.notification, "show");
        sinon.spy(bookmarklet.notification, "message");
        sinon.spy(bookmarklet.notification, "hide");
        return sinon.spy(bookmarklet.notification, "remove");
    });
    afterEach(function() {
        bookmarklet.notification.show.restore();
        bookmarklet.notification.message.restore();
        bookmarklet.notification.hide.restore();
        return bookmarklet.notification.remove.restore();
    });
    it("should have an Element property", function() {
        return assert.isObject(notification.element);
    });
    describe("show", function() {
        it("should set the top style of the element", function() {
            notification.show();
            return assert.equal(parseInt(notification.element.style.top), "0");
        });
        return it("should call notification.message", function() {
            notification.show("hello", "red");
            return assert(notification.message.calledWith("hello", "red"));
        });
    });
    describe("hide", function() {
        return it("should set the top style of the element", function() {
            notification.hide();
            return assert.notEqual(notification.element.style.top, "0px");
        });
    });
    describe("message", function() {
        it("should set the innerHTML of the element", function() {
            notification.message("hello");
            return assert.equal(notification.element.innerHTML, "hello");
        });
        return it("should set the bottomBorderColor of the element", function() {
            var current;
            current = notification.element.style.borderBottomColor;
            notification.message("hello", "#fff");
            return assert.notEqual(notification.element.style.borderBottomColor, current);
        });
    });
    describe("append", function() {
        return it("should append the element to the document.body", function() {
            notification.append();
            return assert.equal(notification.element.parentNode, document.body);
        });
    });
    return describe("remove", function() {
        return it("should remove the element from the document.body", function() {
            notification.remove();
            return assert.isNull(notification.element.parentElement);
        });
    });
});
