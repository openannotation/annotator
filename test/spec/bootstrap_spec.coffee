window._annotatorConfig =
  test: true
  target: "#fixtures"
  externals:
    source: "../notexist/annotator.js"
    styles: "../notexist/annotator.css"

  auth:
    autoFetch: false

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
$ = require('../../src/util').$
require('../../src/bootstrap')


describe "bookmarklet", ->
  bookmarklet = null
  head = document.getElementsByTagName('head')[0]
  body = document.body

  beforeEach ->
    window.Annotator = Annotator
    bookmarklet = window._annotator.bookmarklet

    # Prevent Notifications from being fired.
    sinon.stub bookmarklet.notification, "show"
    sinon.stub bookmarklet.notification, "message"
    sinon.stub bookmarklet.notification, "hide"
    sinon.stub bookmarklet.notification, "remove"

    sinon.spy bookmarklet, "config"
    sinon.stub bookmarklet, "_injectElement", (where, el) ->
      if el.onload?
        el.onload.call()

  afterEach ->
    delete window.Annotator

    bookmarklet.notification.show.restore()
    bookmarklet.notification.message.restore()
    bookmarklet.notification.hide.restore()
    bookmarklet.notification.remove.restore()

    bookmarklet.config.restore()
    bookmarklet._injectElement.restore()

    $(".annotator-bm-status, .annotator-notice").remove()

  describe "init()", ->
    beforeEach ->
      sinon.spy bookmarklet, "load"

    afterEach ->
      bookmarklet.load.restore()

    it "should display a notification telling the user the page is loading", ->
      bookmarklet.init()
      assert(bookmarklet.notification.show.called)

    it "should display a notification if the bookmarklet has loaded", ->
      window._annotator.instance = {}
      window._annotator.Annotator = showNotification: sinon.spy()
      bookmarklet.init()
      assert(window._annotator.Annotator.showNotification.called)

  describe "load()", ->

    it "should append the stylesheet to the head", (done) ->
      bookmarklet.load ->
        assert(bookmarklet._injectElement.calledWith('head'))
        done()

    it "should append the script to the body", (done) ->
      bookmarklet.load ->
        assert(bookmarklet._injectElement.calledWith('body'))
        done()

  describe "setup()", ->
    hasPlugin = (instance, name) ->
      name of instance.plugins

    beforeEach ->
      bookmarklet.setup()

    it "should export useful values to window._annotator", ->
      assert.isFunction(window._annotator.Annotator)
      assert.isObject(window._annotator.instance)
      assert.isFunction(window._annotator.jQuery)
      assert.isObject(window._annotator.element)

    it "should add the plugins to the annotator instance", ->
      instance = window._annotator.instance
      assert(hasPlugin(instance, 'Auth'))
      assert(hasPlugin(instance, 'Store'))
      assert(hasPlugin(instance, 'AnnotateItPermissions'))
      assert(hasPlugin(instance, 'Unsupported'))

    it "should add the tags plugin if options.tags is true", ->
      instance = window._annotator.instance
      assert(hasPlugin(instance, 'Tags'))

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
