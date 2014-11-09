angular.module('loomioApp').factory 'RecordStoreService', ($angularCacheFactory) ->
  new class RecordStoreService
    constructor: ->
      @cache = $angularCacheFactory 'recordStore'
      @models = {}

    registerModel: (model) ->
      thing = new model
      @models[thing.plural] = model

    collectionNames: ->
      _.keys(@models)

    importRecords: (responseData) ->
      _.each @collectionNames(), (collectionName) =>
        if responseData[collectionName]?
          _.each responseData[collectionName], (record_data) =>
            record = new @models[collectionName](record_data)
            @put(record)

    recordKey: (record) ->
      "#{record.plural}/id/#{record.id}"

    altRecordKey: (record) ->
      "#{record.plural}/key/#{record.key}"

    allKeysIn: (collectionName) ->
      _.filter @cache.keys(), (key) ->
        key.match("^#{collectionName}/id/")

    allRecordsIn: (collectionName) ->
      _.map @allKeysIn(collectionName), (key) =>
        @cache.get(key)

    # works in the following variations
    #
    # get 'comments', 5
    # get 'discussions', 'dtft67ygy8u'
    # get 'comments', [5,10,15]
    # get 'motions', ['e3d', 'd3e3e']
    # get 'comments', (comment) -> comment.id == discussion_id
    #
    get: (collectionName, idsOrFn) ->
      if idsOrFn == undefined
        @allRecordsIn(collectionName)
      else if _.isArray(idsOrFn)
        _.map idsOrFn, (id) =>
          @getOne(collectionName, id)
      else if _.isFunction(idsOrFn)
        _.filter @allRecordsIn(collectionName), idsOrFn
      else
        @getOne(collectionName, idsOrFn)

    getOne: (collectionName, idOrKey) ->
      if _.isNumber(idOrKey)
        @getById(collectionName, idOrKey)
      else
        @getByKey(collectionName, idOrKey)

    getById: (collectionName, id) ->
      @cache.get "#{collectionName}/id/#{id}"

    getByKey: (collectionName, key) ->
      @cache.get "#{collectionName}/key/#{key}"

    put: (record) ->
      key = @recordKey(record)
      existing_record = @cache.get(key)
      if existing_record?
        angular.extend(existing_record, record)
      else
        @cache.put key, record
        # if record has .key also store against that
        if record.key?
          altKey = @altRecordKey(record)
          @cache.put altKey, record

    delete: (record) ->
      key = @recordKey(record)
      @cache.remove(key)
      if record.key?
        altKey = @altRecordKey(record)
        @cache.delete(altKey)

