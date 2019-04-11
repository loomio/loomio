export default class RecordStore
  constructor: (db) ->
    @db = db
    @collectionNames = []

  addRecordsInterface: (recordsInterfaceClass) ->
    recordsInterface = new recordsInterfaceClass(@)
    recordsInterface.setRemoteCallbacks(@defaultRemoteCallbacks())
    name = recordsInterface.model.plural
    @[_.camelCase(name)] = recordsInterface
    recordsInterface.onInterfaceAdded()
    @collectionNames.push name

  import: (data) ->
    return if _.isEmpty(data)
    @bumpVersion()
    _.each @collectionNames, (name) =>
      snakeName = _.snakeCase(name)
      camelName = _.camelCase(name)
      if data[snakeName]?
        _.each data[snakeName], (recordData) =>
          @[camelName].importJSON(recordData)
    @afterImport(data)
    data

  afterImport: (data) ->

  setRemoteCallbacks: (callbacks) ->
    _.each @collectionNames, (name) => @[_.camelCase(name)].setRemoteCallbacks(callbacks)

  defaultRemoteCallbacks: ->
    onUploadSuccess: (data) => @import(data)
    onSuccess: (response) =>
      if response.ok
        response.json().then (data) =>
          @import(data)
      else
        throw response
    onFailure: (response) => throw response

  bumpVersion: ->
    @_version = (@_version || 0) + 1

  memoize: (func, obj) ->
    cache = {}
    obj = obj || @
    ->
      args = Array.prototype.slice.call(arguments)
      key = "#{obj._version}#{args.join()}"
      if cache[key]?
        cache[key]
      else
        cache[key] = func.apply(this, arguments)
