angular.module('loomioApp').factory 'BaseRecordsInterface', (RestfulClient) ->
  class BaseRecordsInterface
    model: 'undefinedModel'

    constructor: (recordStore) ->
      @recordStore = recordStore
      @collection = @recordStore.db.addCollection(@model.plural, {indices: @model.indices})
      @restfulClient = new RestfulClient(@model.plural)

      @restfulClient.onSuccess = (response) =>
        @recordStore.import(response.data)

      @restfulClient.onFailure = (response) ->
        console.log('request failure!', response)
        throw response

    initialize: (data = {}) ->
      @baseInitialize(data)

    baseInitialize: (data = {}) ->
      if data.key?
        existingRecord = @find(data.key)
      else if data.id?
        existingRecord = @find(data.id)

      if existingRecord?
        existingRecord.updateFromJSON(data)
        existingRecord
      else
        record = new @model(@, data)
        @collection.insert(record)
        record

    findOrFetchByKey: (key) ->
      promise = @fetchByKey(key).then => @find(key)
      record = @find(key)
      record or promise

    fetchByKey: (key) ->
      @restfulClient.getMember(key)

    fetch: (params) ->
      @restfulClient.getCollection(params)

    where: (params) ->
      @collection.chain().find(params).data()

    # creates and maintains a view. consider costs of this vs where
    # you'll need to call .data() yourself. that's why this is a view
    belongingTo: (params) ->
      @collection.addDynamicView(@viewName(params))
                 .applyFind(params)

    viewName: (params) ->
      _.keys(params).join() + _.values(params).join()

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

    destroy: (id) ->
      @restfulClient.destroy(id)
