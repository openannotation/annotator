# Public: A initialization function that sets up the Annotator and some of the
# default plugins. Intended for use with the annotator-full package.
#
# NOTE: This method is intened to be called via the jQuery .annotator() method
# although it is available directly on the Annotator instance.
#
# config - An Object containing config options for the AnnotateIt store.
#          userId:    AnnotateIt User ID.
#          userName:  Display name string for the annotations.
#          accountId: AnnotateIt Account ID.
#          authToken: AnnotateIt Auth Token.
#          storeUri:  API endpoint for the store (default: "http://annotateit.org/api")
#
# Examples
#
#   $('#content').annotator().annotator('setupPlugins', {
#     userId:    'demo-user',
#     userName:  'Demo User',
#     accountId: 'some-long-acccount-id',
#     authToken: 'an-even-longer-auth-token'
#   });
#
# Returns iteself for chaining.
Annotator::setupPlugins = (config={}) ->
  # Set up the default plugins.
  plugins =
    Tags: {}
    Filter: {}
    Unsupported: {}

  # If Showdown is included add the Markdown plugin.
  plugins.Markdown = {} if window.Showdown

  # Check the options for store credientials and add relevant plugins.
  {userId, userName, accountId, authToken} = config
  if userId and userName and accountId and authToken
    uri = window.location.href.split(/#|\?/).shift()
    $.extend plugins,
      Store:
        prefix: config.storeUri || 'http://annotateit.org/api'
        annotationData:
          'uri': uri
        loadFromSearch:
          uri: uri
          all_fields: 1
      Permissions:
        user:
          id:   options.userId,
          name: options.userName
        permissions:
          read:   [options.userId]
          update: [options.userId]
          delete: [options.userId]
          admin:  [options.userId]
        userId: (user) ->
          if user?.id then user.id else ''
        userString: (user) ->
          if user?.name then user.name else ''

    @element.data
      'annotator:headers':
        'X-Annotator-User-Id':    options.userId
        'X-Annotator-Account-Id': options.accountId
        'X-Annotator-Auth-Token': options.authToken

  this.addPlugin(name, options) for own name, options of plugins
