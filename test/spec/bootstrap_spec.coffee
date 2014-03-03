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

  annotateItPermissions:
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


Annotator = require('annotator')
require('../../src/bootstrap')


describe "bookmarklet", ->
  bookmarklet = null
  head = document.getElementsByTagName('head')[0]

  beforeEach ->
    window.Annotator = Annotator
    bookmarklet = window._annotator.bookmarklet

    # Prevent Notifications from being fired.
    sinon.stub bookmarklet.notification, "show"
    sinon.stub bookmarklet.notification, "message"
    sinon.stub bookmarklet.notification, "hide"
    sinon.stub bookmarklet.notification, "remove"

    sinon.spy bookmarklet, "config"
    sinon.stub bookmarklet, "loadjQuery"

    sinon.stub jQuery, "getScript", (_src, callback) ->
      callback()
      error: ->
    sinon.stub head, "appendChild"

  afterEach ->
    delete window.Annotator

    bookmarklet.notification.show.restore()
    bookmarklet.notification.message.restore()
    bookmarklet.notification.hide.restore()
    bookmarklet.notification.remove.restore()

    bookmarklet.config.restore()
    bookmarklet.loadjQuery.restore()

    jQuery.getScript.restore()
    head.appendChild.restore()

    jQuery(".annotator-bm-status, .annotator-notice").remove()

  describe "init()", ->
    beforeEach ->
      sinon.spy bookmarklet, "load"
      sinon.spy window.jQuery, "proxy"

    afterEach ->
      bookmarklet.load.restore()
      window.jQuery.proxy.restore()

    it "should display a notification telling the user the page is loading", ->
      bookmarklet.init()
      assert(bookmarklet.notification.show.called)

    it "should call jQueryLoad()", ->
      bookmarklet.init()
      assert(bookmarklet.loadjQuery.called)

    it "should display a notification if the bookmarklet has loaded", ->
      window._annotator.instance = {}
      window._annotator.Annotator = showNotification: sinon.spy()
      bookmarklet.init()
      assert(window._annotator.Annotator.showNotification.called)

  describe "load()", ->
    it "should append the stylesheet to the head", (done) ->
      bookmarklet.load ->
        assert(head.appendChild.called)
        done()

    it "should load the annotator script and call the callback", (done) ->
      bookmarklet.load ->
        assert(jQuery.getScript.called)
        done()

  describe "setup()", ->
    beforeEach ->
      bookmarklet.setup()

    afterEach ->
      window._annotator.jQuery("#fixtures").empty().removeData("annotator").removeData "annotator:headers"

    it "should export useful values to window._annotator", ->
      assert.isFunction(window._annotator.Annotator)
      assert.isObject(window._annotator.instance)
      assert.isFunction(window._annotator.jQuery)
      assert.isObject(window._annotator.element)

    it "should add the plugins to the annotator instance", ->
      instance = window._annotator.instance
      plugins = instance.plugins
      assert.isObject(plugins.Auth)
      assert.isObject(plugins.Store)
      assert.isObject(plugins.AnnotateItPermissions)
      assert.isObject(plugins.Unsupported)

    it "should add the tags plugin if options.tags is true", ->
      instance = window._annotator.instance
      plugins = instance.plugins
      assert.isObject(plugins.Tags)

    it "should display a loaded notification", ->
      assert(bookmarklet.notification.message.called)

  describe "annotateItPermissionsOptions()", ->
    it "should return an object literal", ->
      assert.isObject(bookmarklet.annotateItPermissionsOptions())

    it "should retrieve user and permissions from config", ->
      bookmarklet.annotateItPermissionsOptions()
      assert(bookmarklet.config.calledWith "annotateItPermissions")

  describe "storeOptions()", ->
    it "should return an object literal", ->
      assert.isObject(bookmarklet.storeOptions())

    it "should retrieve store prefix from config", ->
      bookmarklet.storeOptions()
      assert(bookmarklet.config.calledWith "store.prefix")

    it "should have set a uri property", ->
      uri = bookmarklet.storeOptions().annotationData.uri
      assert(uri)

describe "bookmarklet.notification", ->
  bookmarklet = null
  notification = undefined

  beforeEach ->
    bookmarklet = window._annotator.bookmarklet
    bookmarklet.init()
    notification = bookmarklet.notification

    sinon.spy bookmarklet.notification, "show"
    sinon.spy bookmarklet.notification, "message"
    sinon.spy bookmarklet.notification, "hide"
    sinon.spy bookmarklet.notification, "remove"

  afterEach ->
    bookmarklet.notification.show.restore()
    bookmarklet.notification.message.restore()
    bookmarklet.notification.hide.restore()
    bookmarklet.notification.remove.restore()

  it "should have an Element property", ->
    assert.isObject(notification.element)

  describe "show", ->
    it "should set the top style of the element", ->
      notification.show()
      assert.equal(notification.element.style.top, "0px")

    it "should call notification.message", ->
      notification.show "hello", "red"
      assert(notification.message.calledWith "hello", "red")

  describe "hide", ->
    it "should set the top style of the element", ->
      notification.hide()
      assert.notEqual(notification.element.style.top, "0px")

  describe "message", ->
    it "should set the innerHTML of the element", ->
      notification.message "hello"
      assert.equal(notification.element.innerHTML, "hello")

    it "should set the bottomBorderColor of the element", ->
      current = notification.element.style.borderBottomColor
      notification.message "hello", "#fff"
      assert.notEqual(notification.element.style.borderBottomColor, current)

  describe "append", ->
    it "should append the element to the document.body", ->
      notification.append()
      assert.equal(notification.element.parentNode, document.body)

  describe "remove", ->
    it "should remove the element from the document.body", ->
      notification.remove()
      assert.isNull(notification.element.parentNode)
