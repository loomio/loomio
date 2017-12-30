module.exports =
  class RecordStore
    constructor: (db) ->
      @db = db
      @collectionNames = []

    addRecordsInterface: (recordsInterfaceClass) ->
      recordsInterface = new recordsInterfaceClass(@)
      name = recordsInterface.model.plural
      @[_.camelCase(name)] = recordsInterface
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
