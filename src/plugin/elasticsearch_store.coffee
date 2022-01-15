# Helper methods for working with elasticsearch. Adds support for storing
# objects as serialized JSON, setting expiry times on stored keys and catching
# exceptions.
# 
# Caught execeptions can be listened for by subscribing to the "error" event
# which will recieve the error object.
#
# Examples
#
#   store = new Store()
#
#   store.set("name", "Aron")
#   store.get("name") #=> Aron
#   store.remove("name")
#
# Returns a new instance of Store.
Annotator.Plugin.Elasticsearch.Store = class Store extends Annotator.Delegator

  constructor: (url, index) ->
    @url = url
    @index = index

  # Internal: Prefix for all keys stored by the store.
  @KEY_PREFIX: "annotator_elasticsearch_"

  # Internal: Delimeter used to seperate the cache time from the value.
  @CACHE_DELIMITER: "--cache--"

  # Public: Checks to see if the current browser supports local storage.
  #
  # Examples
  #
  #   store = new Store if Store.isSupported()
  #
  # Returns true if the browser supports local storage.
  @isSupported: ->
    true

  # Public: Get the current time as a unix timestamp in
  # milliseconds.
  #
  # Examples
  #
  #   Store.now() //=> 1325099398242
  #
  # Returns the current time in milliseconds.
  @now: -> new Date().getTime()

  # Public: Extracts all the values stored under the KEY_PREFIX. An additional
  # partial key can be provided that will be added to the prefix.
  #
  # partial - A partial database key (default: "").
  #
  # Examples
  #
  #   values = store.all()
  #   some   = store.all("user") # All keys beginning with "user"
  #
  # Returns an array of extracted keys.
  all: (partial="") ->
    values = []
    $.ajax "#{@url}/#{@index}/_search?q=*:*&size=2500",
      async: false
      dataType:'json'
      contentType: "application/json"
      success  : (data, status, xhr) ->
        for i of data.hits.hits
          values.push(data.hits.hits[i]._source)
      error : (xhr, status, err) ->
        console.log("error:"+err)
      complete : (xhr, status) ->
        console.log("completed.")
    values

  # Public: Sets a value for the key provided. An optional "expires" time in
  # milliseconds can be provided, the key will not be accessble via #get() after
  # this time.
  #
  # All values will be serialized with JSON.stringify() so ensure that they
  # do not have recursive properties before passing them to #set().
  #
  # key   - A key string to set.
  # value - A value to set.
  # time  - Expiry time in milliseconds (default: null).
  #
  # Examples
  #
  #   store.set("key", 12345)
  #   store.set("temporary", {user: 1}, 3000)
  #   store.get("temporary") #=> {user: 1}
  #   setTimeout ->
  #     store.get("temporary") #=> null
  #   , 3000
  #
  # Returns itself.
  set: (key, value, time) ->
    value = JSON.stringify value
    value = (Store.now() + time) + Store.CACHE_DELIMITER + value if time
    try
      $.ajax "#{@url}/#{@index}/_doc/#{@prefixed(key)}",
        type: 'PUT'
        data: value
        dataType: 'json'
        contentType: "application/json"
        success: (response) ->
            console.log "AJAX Success: #{JSON.stringify(response)}"
        error: (response) ->
            console.log "AJAX Error: #{JSON.stringify(response)}"
    catch error
      this.publish('error', [error, this])
    this

  # Public: Removes the key from the storage.
  #
  # key - The key to remove.
  #
  # Examples
  #
  #   store.set("name", "Aron")
  #   store.remove("key")
  #   store.get("name") #=> null
  #
  # Returns itself.
  remove: (key) ->
    try
      $.ajax "#{@url}/#{@index}/_doc/#{@prefixed(key)}",
        type: 'DELETE'
        success: (response) ->
            console.log "AJAX Success: #{JSON.stringify(response)}"
        error: (response) ->
            console.log "AJAX Error: #{JSON.stringify(response)}"
    catch error
      this.publish('error', [error, this])
    this

  # Public: Removes all keys in local storage with the prefix.
  #
  # Examples
  #
  #   store.clear()
  #
  # Returns itself.
  clear: ->
    this

  # Internal: Applies the KEY_PREFIX to the provided key. This is used to
  # namespace keys in localStorage.
  #
  # key - A user provided key to prefix.
  #
  # Examples
  #
  #   store.prefixed("name") #=> "annotator.readmill/name"
  #
  # Returns a prefixed key.
  prefixed: (key) ->
    Store.KEY_PREFIX + key

  # Internal: Checks the expiry period (if any) of a value extracted from
  # localStorage. Returns the value if it is still valid, otherwise returns
  # null.
  #
  # param - comment
  #
  # Examples
  #
  #   store.checkCache("1325099398242--cache--\"expired\") #=> null
  #   store.checkCache("1325199398242--cache--\"valid\") #=> "valid"
  #
  # Returns extracted value or null if expired.
  checkCache: (value) ->
    if value.indexOf(Store.CACHE_DELIMITER) > -1
      # If the expiry time has passed then return null.
      cached = value.split(Store.CACHE_DELIMITER)
      value = if Store.now() > cached.shift()
      then null else cached.join(Store.CACHE_DELIMITER)
    value
