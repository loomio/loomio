angular.module('loomioApp').service 'RecordStoreService', class RecordStoreService
    constructor: (@$http, @$angularCacheFactory) ->
      @cache = @$angularCacheFactory 'recordStore'
      @models = {}

    registerModel: (model) ->
      thing = new model
      @models[thing.plural] = model

    collectionNames: ->
      _.keys(@models)

    importRecords: (responseData) ->
      _.each @collectionNames(), (collectionName) =>
        #console.log collectionName
        if responseData[collectionName]?
          console.log("importing #{responseData[collectionName].length} #{collectionName} records")
          _.each responseData[collectionName], (record_data) =>
            #console.log "record data: #{collectionName} #{JSON.stringify(record_data)}"
            record = new @models[collectionName](record_data)
            @put(record)

    recordKey: (record) ->
      "#{record.plural}/#{record.id}"

    get: (collectionName, id) ->
      @cache.get "#{collectionName}/#{id}"

    altRecordKey: (record) ->
      "#{record.plural}/key-#{record.key}"

    getByKey: (collectionName, key) ->
      #console.log "getting #{collectionName}/key-#{key}"
      @cache.get "#{collectionName}/key-#{key}"


    getAll: (collectionName, ids) ->
      _.map ids, (id) =>
        #console.log "getting: #{collectionName}/#{id}"
        @cache.get "#{collectionName}/#{id}"

    put: (record) ->
      key = @recordKey(record)
      existing_record = @cache.get(key)
      #console.log "puttng: #{key} : #{JSON.stringify(record)}"
      if existing_record?
        angular.extend(existing_record, record)
      else
        @cache.put key, record
        # if record has .key also store against that
        if record.key?
          altKey = @altRecordKey(record)
          @cache.put altKey, record
