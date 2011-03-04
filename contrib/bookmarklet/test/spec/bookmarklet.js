describe("bookmarklet", function () {
  var bookmarklet = _annotator.bookmarklet;

  beforeEach(function () {
    window._annotator = { bookmarklet: bookmarklet };
    spyOn(bookmarklet.notification, 'show');
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
      window.jQuery = {sub: jasmine.createSpy('jQuery.sub()')};

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
});
