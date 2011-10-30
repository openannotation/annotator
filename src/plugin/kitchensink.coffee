# Public: A initialization function that sets up the Annotator and some of the
# default plugins. Intended for use with the annotator-full package.
#
# NOTE: This method is intened to be called via the jQuery .annotator() method
# although it is available directly on the Annotator instance.
#
# config  - An Object containing config options for the AnnotateIt store.
#           userId:    AnnotateIt User ID.
#           userName:  Display name string for the annotations.
#           accountId: AnnotateIt Account ID.
#           authToken: AnnotateIt Auth Token.
#           storeUri:  API endpoint for the store (default: "http://annotateit.org/api")
# options - An Object containing plugin settings to override the defaults.
#           Setting a filter to null or false will not load the filter.
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
#   // Only display a filter for the user field and disable tags.
#   $('#content').annotator().annotator('setupPlugins', null, {
#     Tags: false,
#     Filter: {
#       filters: [{label: 'User', property: 'user'}],
#       addAnnotationFilter: false
#     }
#   });
#
# Returns iteself for chaining.
Annotator::setupPlugins = (config={}, options={}) ->
  win = util.getGlobal()

  # Set up the default plugins.
  plugins =
    Tags: {}
    Filter:
      filters: [
        {label: _t('User'), property: 'user'}
        {label: _t('Tags'), property: 'tags'}
      ]
    Unsupported: {}

  # If Showdown is included add the Markdown plugin.
  plugins.Markdown = {} if win.Showdown

  # Check the config for store credientials and add relevant plugins.
  {userId, userName, accountId, authToken} = config
  if userId and userName and accountId and authToken
    uri = win.location.href.split(/#|\?/).shift() or ''
    $.extend plugins,
      Store:
        prefix: config.storeUri or 'http://annotateit.org/api'
        annotationData:
          'uri': uri
        loadFromSearch:
          uri: uri
          all_fields: 1
      Permissions:
        user:
          id:   config.userId,
          name: config.userName
        permissions:
          read:   [config.userId]
          update: [config.userId]
          delete: [config.userId]
          admin:  [config.userId]
        userId: (user) ->
          if user?.id then user.id else ''
        userString: (user) ->
          if user?.name then user.name else ''

    @element.data
      'annotator:headers':
        'X-Annotator-User-Id':    config.userId
        'X-Annotator-Account-Id': config.accountId
        'X-Annotator-Auth-Token': config.authToken

  $.extend plugins, options
  for own name, opts of plugins when opts != null and opts != false
    this.addPlugin(name, opts)
