RestfulClient = require './restful_client.coffee'
utils = require './utils.coffee'

module.exports =
  class BaseRecordsInterface
    model: 'undefinedModel'

    constructor: (recordStore) ->
      @baseConstructor recordStore

    baseConstructor: (recordStore) ->
      @recordStore = recordStore
      @collection = @recordStore.db.addCollection(@model.plural, {indices: @model.indices})
      _.each @model.uniqueIndices, (name) =>
        @collection.ensureUniqueIndex(name)

      @remote = new RestfulClient(@model.apiEndPoint or @model.plural)

      @remote.onSuccess = (response) =>
        response.json().then (data) =>
          @recordStore.import(data) if response.ok
          data

      @remote.onUploadSuccess = (data) =>
        @recordStore.import(data)

      @remote.onFailure = (response) ->
        console.log('request failure!', response)
        throw response

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

    findOrFetchById: (id, params = {}) ->
      if record = @find(id)
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
