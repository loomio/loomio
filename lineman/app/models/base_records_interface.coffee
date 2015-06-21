angular.module('loomioApp').factory 'BaseRecordsInterface', (RestfulClient, $q) ->
  class BaseRecordsInterface
    model: 'undefinedModel'

    constructor: (recordStore) ->
      @recordStore = recordStore
      @collection = @recordStore.db.addCollection(@model.plural, {indices: @model.indices})
      @restfulClient = new RestfulClient(@model.plural)
      @latestCache = {}

      @restfulClient.onSuccess = (response) =>
        @recordStore.import(response.data)

      @restfulClient.onFailure = (response) ->
        console.log('request failure!', response)
        throw response

    build: (data = {}) ->
      new @model @, data

    import: (data = {}) ->
      @baseImport(data)

    baseImport: (data = {}) ->
      if record = @find(data.key or data.id)
        record.updateFromJSON(data)
      else
        @collection.insert(record = @build(data))

      record

    findOrFetchByKey: (key) ->
      deferred = $q.defer()
      promise = @fetchByKey(key).then => @find(key)

      if record = @find(key)
        deferred.resolve(record)
      else
        deferred.resolve(promise)

      deferred.promise

    fetchByKey: (key) ->
      @restfulClient.getMember(key)

    fetch: ({params, path, cacheKey}) ->
      if cacheKey
        lastFetchedAt = @applyLatestFetch(cacheKey)
        params.since = lastFetchedAt if params? and lastFetchedAt?

      if path?
        @restfulClient.get(path, params)
      else
        @restfulClient.getCollection(params)

    applyLatestFetch: (cacheKey) ->
      lastFetchedAt = @latestCache[cacheKey]
      @latestCache[cacheKey] = moment().toDate()
      lastFetchedAt

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
      if q == null or q == undefined
        null
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
        @collection.find(q)

    findById: (id) ->
      @collection.findOne(id: id)

    findByKey: (key) ->
      @collection.findOne(key: key)

    findByIds: (ids) ->
      @collection.find(id: {'$in': ids})

    findByKeys: (keys) ->
      @collection.find(key: {'$in': keys})

    destroy: (id) ->
      @restfulClient.destroy(id)
