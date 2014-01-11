angular.module('loomioApp').service 'RecordCacheService',
  class RecordCacheService
    constructor: (@$http, @$angularCacheFactory) ->
      @cache = @$angularCacheFactory 'recordCache'

    recordKey: (collectionName, id) ->
      "#{collectionName}/#{id}"

    consumeSideLoadedRecords: (rootNode, knownRecordKeys) ->
      _.each knownRecordKeys, (collection) =>
        if rootNode[collection]?
          _.each rootNode[collection], (record) =>
            @cache.put @recordKey(collection, record.id), record

    localGet: (collectionName, id)->
      @cache.get @recordKey(collectionName, id)

    hydrateRelationshipsOn: (record) ->
      if record.relationships?
        _.each record.relationships, (options, key) =>
          switch options.type
            when 'list'
              _.each record[options.foreign_key], (id) =>
                record[key] = [] unless record.key?
                record[key].push @cache.get(@recordKey(options.collection, id))
            else
              record[key] = @cache.get(@recordKey options.collection, record[options.foreign_key])
      else
        console.log("record has no relationships: #{record}")
