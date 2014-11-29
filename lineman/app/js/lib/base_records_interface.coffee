angular.module('loomioApp').factory 'BaseRecordsInterface', (RestfulClient) ->
  class BaseRecordsInterface
    @model: 'undefinedModel'
    @restfulClient: 'undefinedRestfulClient'

    constructor: (recordStore) ->
      @recordStore = recordStore
      @collection = @recordStore.db.addCollection(@constructor.model.plural)
      @constructor.restfulClient = new RestfulClient(@constructor.model.plural)

    restfulClient: ->
      @constructor.restfulClient

    # this method should only be called by model instances
    save: (record) ->
      if record.isNew()
        @restfulClient.create()

    put: (data) ->
      if data.key?
        existingRecord = @get(data.key)
      else if data.id?
        existingRecord = @get(data.id)

      if existingRecord?
        @update(data)
      else
        @new(data)

    update: (data) ->
      existingRecord.initialize(data)
      existingRecord

    new: (data) ->
      record = new @constructor.model(@recordStore, data)
      @collection.insert(record) if data.id?
      record

    get: (q) ->
      if _.isNumber(q)
        @getById(q)
      else if _.isString(q)
        @getByKey(q)
      else if _.isArray(q)
        if q.length == 0
          []
        else if _.isString(q[0])
          @getByKeys(q)
        else if _.isNumber(q[0])
          @getByIds(q)
      else
        'weird input'

    getById: (id) ->
      @collection.find(id: id)[0]

    getByKey: (key) ->
      @collection.find(key: key)[0]

    getByIds: (ids) ->
      @collection.find(id: {'$in': ids})

    getByKeys: (keys) ->
      @collection.find(key: {'$in': keys})
