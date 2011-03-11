describe("bookmarklet", function () {
  var bookmarklet;

  beforeEach(function () {
    runBookmarklet();

    bookmarklet = window._annotator.bookmarklet;
    
    // Prevent Notifications from being fired.
    spyOn(bookmarklet.notification, 'show');
    spyOn(bookmarklet.notification, 'message');
    spyOn(bookmarklet.notification, 'hide');
    spyOn(bookmarklet.notification, 'remove');
  });

  afterEach(function () {
    // Remove all traces of the bookmarklet.
    delete window._annotator;
    jQuery('.annotator-bm-status, .annotator-notice').remove();
  });

  describe("init()", function () {
    beforeEach(function () {
      spyOn(bookmarklet, 'loadjQuery');
      spyOn(bookmarklet, 'load');
    });

    it("should display a notification telling the user the page is loading", function () {
      bookmarklet.init();
      expect(bookmarklet.notification.show).toHaveBeenCalled();
    });

    it("should call load() if jQuery is on the page", function () {
      var jQuery = window.jQuery;
      window.jQuery = {
        sub: jasmine.createSpy('jQuery.sub()'),
        proxy: jasmine.createSpy('jQuery.proxy()')
      };
      window.jQuery.sub.andReturn(window.jQuery);

      bookmarklet.init();
      expect(bookmarklet.load).toHaveBeenCalled();
      expect(window.jQuery.sub).toHaveBeenCalled();

      window.jQuery = jQuery;
    });

    it("should call jQueryLoad() if jQuery is not on the page", function () {
      var _$ = window.jQuery.noConflict(true);

      bookmarklet.init();
      expect(bookmarklet.loadjQuery).toHaveBeenCalled();

      window.jQuery = _$;
    });

    it("should display a notification if the bookmarklet has loaded", function () {
      window._annotator.instance = {};
      window._annotator.Annotator = {
        showNotification: jasmine.createSpy()
      };

      bookmarklet.init();
      expect(window._annotator.Annotator.showNotification).toHaveBeenCalled();
    });
  });

  describe("load()", function () {
    beforeEach(function () {
      spyOn(bookmarklet, 'setup');
      bookmarklet.init();
    });

    afterEach(function () {
      var head = document.getElementsByTagName('head')[0];
      var stylesheets = document.getElementsByTagName('link');
    });

    it("should append the stylesheet to the head", function () {
      var stylesheets = document.getElementsByTagName('link'),
          count = stylesheets.length;

      bookmarklet.load(function () {});

      expect(stylesheets.length).toEqual(count + 1);
    });

    it("should load the annotator script and call the callback", function () {
      var callback = jasmine.createSpy('callback');
      bookmarklet.load(callback);
      waitsFor(function () {
        return callback.wasCalled;
      });
      runs(function () {
        expect(callback).toHaveBeenCalled();
      });
    });
  });

  describe("loadjQuery()", function () {
    it("should load jQuery into the page and call bookmarklet.load()", function () {
      spyOn(bookmarklet, 'load');

      bookmarklet.loadjQuery();
      waitsFor(function () {
        return !!bookmarklet.load.wasCalled;
      });
      runs(function () {
        expect(bookmarklet.load).toHaveBeenCalled();
      });
    });
  });

  describe("setup()", function () {
    beforeEach(function () {
      bookmarklet.setup();
    });

    afterEach(function () {
      window._annotator.jQuery('#fixtures')
        .empty()
        .removeData('annotator')
        .removeData('annotator:headers');
    });

    it("should export useful values to window._annotator", function () {
      expect(window._annotator.Annotator).toBeTruthy();
      expect(window._annotator.instance).toBeTruthy();
      expect(window._annotator.jQuery).toBeTruthy();
      expect(window._annotator.element).toBeTruthy();
    });

    it("should add the plugins to the annotator instance", function () {
      var instance = window._annotator.instance,
          plugins  = instance.plugins;

      expect(plugins.Store).toBeTruthy();
      expect(plugins.Permissions).toBeTruthy();
      expect(plugins.Unsupported).toBeTruthy();
      expect(instance.element.data('annotator:headers')).toBeTruthy();
    });

    it ("should add the tags plugin if options.tags is true", function () {
      var instance = window._annotator.instance,
          plugins  = instance.plugins;

      expect(plugins.Tags).toBeTruthy();
    });

    it("should display a loaded notification", function () {
      expect(bookmarklet.notification.message).toHaveBeenCalled();
    });
  });

  describe("permissionsOptions()", function () {
    it("should return an object literal", function () {
      expect(typeof bookmarklet.permissionsOptions()).toEqual('object');
    });

    it("should retrieve user and permissions from config", function () {
      spyOn(bookmarklet, 'config');
      spyOn(jQuery, 'extend');
      bookmarklet.permissionsOptions();
      expect(jQuery.extend).toHaveBeenCalled();
      expect(bookmarklet.config).toHaveBeenCalledWith('permissions');
    });

    it("should have a userId method that returns the user id", function () {
      var userId = bookmarklet.permissionsOptions().userId;

      expect(userId({id: 'myId'})).toEqual('myId');
      expect(userId({})).toEqual('');
      expect(userId(null)).toEqual('');
    });

    it("should have a userString method that returns the username", function () {
      var userString = bookmarklet.permissionsOptions().userString;

      expect(userString({name: 'bill'})).toEqual('bill');
      expect(userString({})).toEqual('');
      expect(userString(null)).toEqual('');
    });
  });

  describe("storeOptions()", function () {
    it("should return an object literal", function () {
      expect(typeof bookmarklet.storeOptions()).toEqual('object');
    });

    it("should retrieve store prefix from config", function () {
      spyOn(bookmarklet, 'config');
      bookmarklet.storeOptions();
      expect(bookmarklet.config).toHaveBeenCalledWith('store.prefix');
    });

    it("should have set a uri property", function () {
      var uri = bookmarklet.storeOptions().annotationData.uri;
      expect(uri).toBeTruthy();
    });
  });
});

describe("bookmarklet.notification", function () {
  var notification;

  runBookmarklet();
  notification = window._annotator.bookmarklet.notification;

  it("should have an Element property", function () {
    expect(notification.element).toBeTruthy();
  });

  describe("show", function () {
    it("should set the top style of the element", function () {
      notification.show();
      expect(notification.element.style.top).toEqual("0px");
    });

    it("should call notification.message", function () {
      spyOn(notification, 'message');
      notification.show('hello', 'red');
      expect(notification.message).toHaveBeenCalledWith('hello', 'red');
    });
  });

  describe("hide", function () {
    it("should set the top style of the element", function () {
      notification.hide();
      expect(notification.element.style.top).not.toEqual("0px");
    });
  });

  describe("message", function () {
    it("should set the innerHTML of the element", function () {
      notification.message('hello');
      expect(notification.element.innerHTML).toEqual("hello");
    });

    it("should set the bottomBorderColor of the element", function () {
      var current = notification.element.style.borderBottomColor;
      notification.message('hello', '#fff');
      expect(notification.element.style.borderBottomColor).not.toEqual(current);
    });
  });

  describe("append", function () {
    it("should append the element to the document.body", function () {
      notification.append();
      expect(notification.element.parentNode).toEqual(document.body);
    });
  });

  describe("remove", function () {
    it("should remove the element from the document.body", function () {
      notification.remove();
      expect(notification.element.parentNode).toBeFalsy();
    });
  });
});
