RestfulClient = require './restful_client'
utils         = require './utils'

module.exports =
  class BaseRecordsInterface
    model: 'undefinedModel'

    # override this if your apiEndPoint is not the model.plural
    apiEndPoint: null

    constructor: (recordStore) ->
      @baseConstructor recordStore

    baseConstructor: (recordStore) ->
      @recordStore = recordStore
      @collection = @recordStore.db.addCollection(@collectionName or @model.plural, {indices: @model.indices})
      _.each @model.uniqueIndices, (name) =>
        @collection.ensureUniqueIndex(name)

      @remote = new RestfulClient(@apiEndPoint or @model.plural)

    onInterfaceAdded: ->

    setRemoteCallbacks: (callbacks) ->
      _.merge @remote, _.pick(callbacks, ['onPrepare', 'onSuccess', 'onUploadSuccess', 'onFailure', 'onCleanup'])

    all: ->
      @collection.data

    build: (attributes = {}) ->
      record = new @model @, attributes

    create: (attributes = {}) ->
      record = @build(attributes)
      @collection.insert(record)
      record

    fetch: (args) ->
      @remote.fetch(args)

    importJSON: (json) ->
      @import(utils.parseJSON(json))

    import: (attributes) ->
      record = @find(attributes.key) if attributes.key?
      record = @find(attributes.id) if attributes.id? and !record?
      if record
        record.update(attributes)
      else
        record = @create(attributes)
      record

    findOrFetchById: (id, params = {}, ensureComplete = false) ->
      record = @find(id)
      if record and (!ensureComplete || record.complete)
        Promise.resolve(record)
      else
        @remote.fetchById(id, params).then => @find(id)

    find: (q) ->
      if q == null or q == undefined
        undefined
      else if _.isNumber(q)
        @findById(q)
      else if _.isString(q)
        @findByKey(q)
      else if _.isArray(q)
        if q.length == 0
          []
        else if _.isString(q[0])
          @findByKeys(q)
        else if _.isNumber(q[0])
          @findByIds(q)
      else
        chain = @collection.chain()
        _.each _.keys(q), (key) ->
          chain.find("#{key}": q[key])
          true
        chain.data()

    findById: (id) ->
      @collection.by('id', id)

    findByKey: (key) ->
      if @collection.constraints.unique['key']?
        @collection.by('key', key)
      else
        @collection.findOne(key: key)

    findByIds: (ids) ->
      @collection.find(id: {'$in': ids})

    findByKeys: (keys) ->
      @collection.find(key: {'$in': keys})
