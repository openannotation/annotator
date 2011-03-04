describe("bookmarklet", function () {
  var bookmarklet = _annotator.bookmarklet;

  beforeEach(function () {
    window._annotator = {bookmarklet: bookmarklet}
  });

  describe("init()", function () {
    beforeEach(function () {
      spyOn(bookmarklet, 'loadjQuery');
      spyOn(bookmarklet, 'load');
      spyOn(bookmarklet.notification, 'show');
    });

    it("should display a notification telling the user the page is loading", function () {
      bookmarklet.init()
      expect(bookmarklet.notification.show).toHaveBeenCalled();
    });
  
    it("should call load() if jQuery is on the page", function () {
      var jQuery = window.jQuery;
      window.jQuery = {sub: jasmine.createSpy('jQuery.sub()')};

      bookmarklet.init()
      expect(bookmarklet.load).toHaveBeenCalled();
      expect(window.jQuery.sub).toHaveBeenCalled();

      window.jQuery = jQuery;
    });
  
    it("should call jQueryLoad() if jQuery is not on the page", function () {
      bookmarklet.init()
      expect(bookmarklet.loadjQuery).toHaveBeenCalled();
    });
  
    it("should display a notification if the bookmarklet has loaded", function () {
      window._annotator.instance = {};
      window._annotator.Annotator = {showNotification: jasmine.createSpy()}

      bookmarklet.init()
      expect(window._annotator.Annotator.showNotification).toHaveBeenCalled();
    });
  });
});
