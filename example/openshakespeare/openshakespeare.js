OpenShakespeare = ("OpenShakespeare" in window) ? OpenShakespeare : {}

OpenShakespeare.Annotator = function (element) {
  var $ = jQuery, self = this

  this.annotator = $(element).annotator().data('annotator')
  this.currentUser = null

  this.options = {
    user: {
      display: function () { self.displayUser.apply(self, arguments) }
    },

    store: {
      prefix: 'http://localhost:5000'
    }
  }

  // Init
  ;(function () {
     self.userPlugin = self.annotator.addPlugin(Annotator.Plugins.User, self.options.user)
     self.storePlugin = self.annotator.addPlugin(Annotator.Plugins.Store, self.options.store)
  })()

  this.setCurrentUser = function (user) {
    self.currentUser = user
    self.storePlugin.setAnnotationData({
      user: self.currentUser
    })
  }

  this.displayUser = function (elem, user) {
    // First, hide the controls for users other than the annotation's owner
    var controls = $(elem).find('.' + self.annotator.getComponentClassname('controls'))

    if (user === self.currentUser) {
      controls.show()
    } else {
      controls.hide()
    }

    // Now, add the username to the annotation
    $(elem).append('<span class="os-annot-username">' + user + '</span>')
  }

  return this
}