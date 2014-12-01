angular.module('loomioApp').factory 'BaseRecordsInterface', (RestfulClient) ->
  class BaseRecordsInterface
    model: 'undefinedModel'
    restfulClient: 'undefinedRestfulClient'

    constructor: (recordStore) ->
      @recordStore = recordStore
      @collection = @recordStore.db.addCollection(@model.plural)
      @restfulClient = new RestfulClient(@model.plural)

    initialize: (data) ->
      if data.key?
        existingRecord = @find(data.key)
      else if data.id?
        existingRecord = @find(data.id)

      if existingRecord?
        existingRecord.initialize(data)
        existingRecord
      else
        record = new @model(@, data)
        @collection.insert(record) if data.id?
        record

    findOrFetchByKey: (key) ->
      if record = @find(key)
        console.log 'found record', record
        @fetchByKey(key)
        record
      else
        console.log 'fetching record', key
        @fetchByKey(key)

    fetchByKey: (key, success, failure) ->
      @restfulClient.getMember key,
        (data) => # success
          console.log 'importing: ', data
          @recordStore.import(data)
          success() if success?
          @find(key)
      ,
        (response) -> # failure
          console.log 'fetch failed', params
          failure() if failure?

    fetch: (params, success, failure) ->
      @restfulClient.getCollection params,
        (data) => # success
          @recordStore.import(data)
          success(data)
      ,
        (response) -> # failure
          console.log 'fetch failed', params, response
          failure(response)

    save: (record, s, f) ->
      if !record.initialize?
        # record is just a hash of params
        @restfulClient.create(record, s, f)
      else
        if record.isNew()
          @restfulClient.create(record.serialize(), s, f)
        else
          @restfulClient.update(record.keyOrId(), record.serialize(), s, f)

    create: (record, s, f) ->
      if !record.initialize?
        # record is just a hash of params
        @restfulClient.create(record, s, f)
      else
        @restfulClient.create(record.serialize(), s, f)

    destroy: (record, s, f) ->
      @restfulClient.destroy(record.id, s, f)

    update: (record, s, f) ->
      @restfulClient.update(record.id, record.serialize(), s, f)

    find: (q) ->
      if _.isNumber(q)
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
        @collection.find(q)

    findById: (id) ->
      @collection.find(id: id)[0]

    findByKey: (key) ->
      @collection.find(key: key)[0]

    findByIds: (ids) ->
      @collection.find(id: {'$in': ids})

    findByKeys: (keys) ->
      @collection.find(key: {'$in': keys})

    importAndInvoke: (callback) ->
      (data) =>
        @recordStore.import(data)
        callback(data) if callback?

    importResponseData: ->
      (data) =>
        @recordStore.import(data)
