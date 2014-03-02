runBookmarklet = ->
  require('../../src/bootstrap')

describe "bookmarklet", ->
  bookmarklet = undefined
  beforeEach ->
    window._annotatorConfig =
      test: true
      target: "#fixtures"
      externals:
        jQuery: "../../../lib/vendor/jquery.js"
        source: "../pkg/annotator.min.js"
        styles: "../pkg/annotator.min.css"

      auth:
        headers:
          "X-Annotator-Account-Id": "39fc339cf058bd22176771b3e30155a8"
          "X-Annotator-User-Id": "aron"
          "X-Annotator-Auth-Token": "65b4e7d823c91d9b18e649e4067f11c3eb29c3cb504ff965760d737ae6dbcdd3"

      tags: true
      store:
        prefix: ""

      permissions:
        showViewPermissionsCheckbox: true
        showEditPermissionsCheckbox: true
        user:
          id: "Aron"
          name: "Aron"

        permissions:
          read: ["Aron"]
          update: ["Aron"]
          delete: ["Aron"]
          admin: ["Aron"]
    runBookmarklet()
    bookmarklet = window._annotator.bookmarklet

    # Prevent Notifications from being fired.
    spyOn bookmarklet.notification, "show"
    spyOn bookmarklet.notification, "message"
    spyOn bookmarklet.notification, "hide"
    spyOn bookmarklet.notification, "remove"
    return

  afterEach ->
    # Remove all traces of the bookmarklet.
    delete window._annotator

    jQuery(".annotator-bm-status, .annotator-notice").remove()

  describe "init()", ->
    beforeEach ->
      spyOn bookmarklet, "loadjQuery"
      spyOn bookmarklet, "load"

    it "should display a notification telling the user the page is loading", ->
      bookmarklet.init()
      expect(bookmarklet.notification.show).toHaveBeenCalled()

    it "should call load() if jQuery is on the page", ->
      jQuery = window.jQuery
      window.jQuery =
        sub: jasmine.createSpy("jQuery.sub()")
        proxy: jasmine.createSpy("jQuery.proxy()")

      window.jQuery.sub.andReturn window.jQuery
      bookmarklet.init()
      expect(bookmarklet.load).toHaveBeenCalled()
      expect(window.jQuery.sub).toHaveBeenCalled()
      window.jQuery = jQuery

    it "should call jQueryLoad() if jQuery is not on the page", ->
      _$ = window.jQuery.noConflict(true)
      bookmarklet.init()
      expect(bookmarklet.loadjQuery).toHaveBeenCalled()
      window.jQuery = _$

    it "should display a notification if the bookmarklet has loaded", ->
      window._annotator.instance = {}
      window._annotator.Annotator = showNotification: jasmine.createSpy()
      bookmarklet.init()
      expect(window._annotator.Annotator.showNotification).toHaveBeenCalled()

  describe "load()", ->
    beforeEach ->
      spyOn bookmarklet, "setup"
      bookmarklet.init()

    afterEach ->
      head = document.getElementsByTagName("head")[0]
      stylesheets = document.getElementsByTagName("link")

    it "should append the stylesheet to the head", ->
      stylesheets = document.getElementsByTagName("link")
      count = stylesheets.length
      bookmarklet.load ->

      expect(stylesheets.length).toEqual count + 1

    it "should load the annotator script and call the callback", ->
      callback = jasmine.createSpy("callback")
      bookmarklet.load callback
      waitsFor ->
        callback.wasCalled

      runs ->
        expect(callback).toHaveBeenCalled()

  describe "loadjQuery()", ->
    it "should load jQuery into the page and call bookmarklet.load()", ->
      spyOn bookmarklet, "load"
      bookmarklet.loadjQuery()
      waitsFor ->
        !!bookmarklet.load.wasCalled

      runs ->
        expect(bookmarklet.load).toHaveBeenCalled()

  describe "setup()", ->
    beforeEach ->
      bookmarklet.setup()

    afterEach ->
      window._annotator.jQuery("#fixtures").empty().removeData("annotator").removeData "annotator:headers"

    it "should export useful values to window._annotator", ->
      expect(window._annotator.Annotator).toBeTruthy()
      expect(window._annotator.instance).toBeTruthy()
      expect(window._annotator.jQuery).toBeTruthy()
      expect(window._annotator.element).toBeTruthy()

    it "should add the plugins to the annotator instance", ->
      instance = window._annotator.instance
      plugins = instance.plugins
      expect(plugins.Store).toBeTruthy()
      expect(plugins.Permissions).toBeTruthy()
      expect(plugins.Unsupported).toBeTruthy()
      expect(instance.element.data("annotator:headers")).toBeTruthy()

    it "should add the tags plugin if options.tags is true", ->
      instance = window._annotator.instance
      plugins = instance.plugins
      expect(plugins.Tags).toBeTruthy()

    it "should display a loaded notification", ->
      expect(bookmarklet.notification.message).toHaveBeenCalled()

  describe "permissionsOptions()", ->
    it "should return an object literal", ->
      expect(typeof bookmarklet.permissionsOptions()).toEqual "object"

    it "should retrieve user and permissions from config", ->
      spyOn bookmarklet, "config"
      spyOn jQuery, "extend"
      bookmarklet.permissionsOptions()
      expect(jQuery.extend).toHaveBeenCalled()
      expect(bookmarklet.config).toHaveBeenCalledWith "permissions"

    it "should have a userId method that returns the user id", ->
      userId = bookmarklet.permissionsOptions().userId
      expect(userId(id: "myId")).toEqual "myId"
      expect(userId({})).toEqual ""
      expect(userId(null)).toEqual ""

    it "should have a userString method that returns the username", ->
      userString = bookmarklet.permissionsOptions().userString
      expect(userString(name: "bill")).toEqual "bill"
      expect(userString({})).toEqual ""
      expect(userString(null)).toEqual ""

  describe "storeOptions()", ->
    it "should return an object literal", ->
      expect(typeof bookmarklet.storeOptions()).toEqual "object"

    it "should retrieve store prefix from config", ->
      spyOn bookmarklet, "config"
      bookmarklet.storeOptions()
      expect(bookmarklet.config).toHaveBeenCalledWith "store.prefix"

    it "should have set a uri property", ->
      uri = bookmarklet.storeOptions().annotationData.uri
      expect(uri).toBeTruthy()

describe "bookmarklet.notification", ->
  notification = undefined
  runBookmarklet()
  notification = window._annotator.bookmarklet.notification

  it "should have an Element property", ->
    expect(notification.element).toBeTruthy()

  describe "show", ->
    it "should set the top style of the element", ->
      notification.show()
      expect(notification.element.style.top).toEqual "0px"

    it "should call notification.message", ->
      spyOn notification, "message"
      notification.show "hello", "red"
      expect(notification.message).toHaveBeenCalledWith "hello", "red"

  describe "hide", ->
    it "should set the top style of the element", ->
      notification.hide()
      expect(notification.element.style.top).not.toEqual "0px"

  describe "message", ->
    it "should set the innerHTML of the element", ->
      notification.message "hello"
      expect(notification.element.innerHTML).toEqual "hello"

    it "should set the bottomBorderColor of the element", ->
      current = notification.element.style.borderBottomColor
      notification.message "hello", "#fff"
      expect(notification.element.style.borderBottomColor).not.toEqual current

  describe "append", ->
    it "should append the element to the document.body", ->
      notification.append()
      expect(notification.element.parentNode).toEqual document.body

  describe "remove", ->
    it "should remove the element from the document.body", ->
      notification.remove()
      expect(notification.element.parentNode).toBeFalsy()
