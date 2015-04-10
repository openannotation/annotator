var assert = require('assertive-chai').assert;

var Annotator = require('annotator'),
    $ = require('../../src/util').$;

require('../../src/bootstrap');

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


describe("bookmarklet", function () {
    var bookmarklet = null;

    beforeEach(function () {
        window.Annotator = Annotator;
        bookmarklet = window._annotator.bookmarklet;

        // Prevent Notifications from being fired
        sinon.stub(bookmarklet.notification, "show");
        sinon.stub(bookmarklet.notification, "message");
        sinon.stub(bookmarklet.notification, "hide");
        sinon.stub(bookmarklet.notification, "remove");

        sinon.spy(bookmarklet, "config");

        sinon.stub(bookmarklet, "_injectElement", function (where, el) {
            if (typeof el.onload == "function") {
                el.onload.call();
            }
        });
    });

    afterEach(function () {
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
        $(".annotator-bm-status, .annotator-notice").remove();
    });

    describe("init()", function () {
        beforeEach(function () {
            sinon.spy(bookmarklet, "load");
        });

        afterEach(function () {
            bookmarklet.load.restore();
        });

        it("should display a notification telling the user the page is loading", function () {
            bookmarklet.init();
            assert(bookmarklet.notification.show.called);
        });

        it("should display a notification if the bookmarklet has loaded", function () {
            window._annotator.instance = {};
            window._annotator.Annotator = {
                showNotification: sinon.spy()
            };
            bookmarklet.init();
            assert(window._annotator.Annotator.showNotification.called);
        });
    });

    describe("load()", function () {
        it("should append the stylesheet to the head", function (done) {
            bookmarklet.load(function () {
                assert(bookmarklet._injectElement.calledWith('head'));
                done();
            });
        });

        it("should append the script to the body", function (done) {
            bookmarklet.load(function () {
                assert(bookmarklet._injectElement.calledWith('body'));
                done();
            });
        });
    });

    describe("setup()", function () {
        function hasPlugin(instance, name) {
            return name in instance.plugins;
        }

        beforeEach(function () {
            bookmarklet.setup();
        });

        it("should export useful values to window._annotator", function () {
            assert.isFunction(window._annotator.Annotator);
            assert.isObject(window._annotator.instance);
            assert.isFunction(window._annotator.jQuery);
            assert.isObject(window._annotator.element);
        });

        it("should add the plugins to the annotator instance", function () {
            var instance = window._annotator.instance;
            assert(hasPlugin(instance, 'Auth'));
            assert(hasPlugin(instance, 'Store'));
            assert(hasPlugin(instance, 'AnnotateItPermissions'));
            assert(hasPlugin(instance, 'Unsupported'));
        });

        it("should add the tags plugin if options.tags is true", function () {
            var instance = window._annotator.instance;
            assert(hasPlugin(instance, 'Tags'));
        });

        it("should display a loaded notification", function () {
            assert(bookmarklet.notification.message.called);
        });
    });

    describe("annotateItPermissionsOptions()", function () {
        it("should return an object literal", function () {
            assert.isObject(bookmarklet.annotateItPermissionsOptions());
        });

        it("should retrieve user and permissions from config", function () {
            bookmarklet.annotateItPermissionsOptions();
            assert(bookmarklet.config.calledWith("annotateItPermissions"));
        });
    });

    describe("storeOptions()", function () {
        it("should return an object literal", function () {
            assert.isObject(bookmarklet.storeOptions());
        });

        it("should retrieve store prefix from config", function () {
            bookmarklet.storeOptions();
            assert(bookmarklet.config.calledWith("store.prefix"));
        });

        it("should have set a uri property", function () {
            var uri = bookmarklet.storeOptions().annotationData.uri;
            assert(uri);
        });
    });
});

describe("bookmarklet.notification", function () {
    var bookmarklet, notification;
    bookmarklet = null;
    notification = void 0;
    beforeEach(function () {
        bookmarklet = window._annotator.bookmarklet;
        notification = bookmarklet.notification;
        sinon.spy(bookmarklet.notification, "show");
        sinon.spy(bookmarklet.notification, "message");
        sinon.spy(bookmarklet.notification, "hide");
        return sinon.spy(bookmarklet.notification, "remove");
    });
    afterEach(function () {
        bookmarklet.notification.show.restore();
        bookmarklet.notification.message.restore();
        bookmarklet.notification.hide.restore();
        return bookmarklet.notification.remove.restore();
    });
    it("should have an Element property", function () {
        return assert.isObject(notification.element);
    });
    describe("show", function () {
        it("should set the top style of the element", function () {
            notification.show();
            return assert.equal(parseInt(notification.element.style.top, 10), "0");
        });
        return it("should call notification.message", function () {
            notification.show("hello", "red");
            return assert(notification.message.calledWith("hello", "red"));
        });
    });
    describe("hide", function () {
        return it("should set the top style of the element", function () {
            notification.hide();
            return assert.notEqual(notification.element.style.top, "0px");
        });
    });
    describe("message", function () {
        it("should set the innerHTML of the element", function () {
            notification.message("hello");
            return assert.equal(notification.element.innerHTML, "hello");
        });
        return it("should set the bottomBorderColor of the element", function () {
            var current;
            current = notification.element.style.borderBottomColor;
            notification.message("hello", "#fff");
            return assert.notEqual(notification.element.style.borderBottomColor, current);
        });
    });
    describe("append", function () {
        return it("should append the element to the document.body", function () {
            notification.append();
            return assert.equal(notification.element.parentNode, document.body);
        });
    });
    return describe("remove", function () {
        return it("should remove the element from the document.body", function () {
            notification.remove();
            return assert.isNull(notification.element.parentElement);
        });
    });
});
