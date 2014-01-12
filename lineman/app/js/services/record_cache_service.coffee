angular.module('loomioApp').service 'RecordCacheService',
  class RecordCacheService
    collectionNames =  ['discussions', 'proposals', 'authors', 'events', 'comments']
    constructor: (@$http, @$angularCacheFactory) ->
      @cache = @$angularCacheFactory 'recordCache'

    recordKey: (collectionName, id) ->
      "#{collectionName}/#{id}"

    consumeSideLoadedRecords: (rootNode) ->
      _.each collectionNames, (collection) =>
        if rootNode[collection]?
          _.each rootNode[collection], (record) =>
            key = @recordKey(collection, record.id)
            #console.log('put', key,  collection, record)
            @cache.put key, record

    get: (collectionname, id)->
      @cache.get @recordKey(collectionname, id)

    put: (collectionName, id, record)->
      if old_record = @cache.get @recordKey(collectionName, id)
        angular.extend(old_record, record)
      else
        @cache.put @recordKey(collectionName, id), record

    hydrateRelationshipsOn: (record) ->
      if record.relationships?
        _.each record.relationships, (options, key) =>
          associated_record = null
          switch options.type
            when 'list'
              _.each record[options.foreign_key], (id) =>
                record[key] = [] unless record[key]?
                associated_record = @cache.get(@recordKey(options.collection, id))
                record[key].push associated_record
                @hydrateRelationshipsOn(associated_record) if associated_record?
            else
              associated_record = @cache.get(@recordKey options.collection, record[options.foreign_key])
              record[key] = associated_record
              @hydrateRelationshipsOn(associated_record) if associated_record?
      else
        console.log("record has no relationships: #{record}")

    #consumeEvent: (event) ->
      #discussion = null
      #if _.isNumber?(event.discussion_id)
        #discussion = @get('discussions', event.discussion_id)
        #discussion.events.push(event)

      #switch event.kind
        #when 'new_comment'
          ##last comment at
        #when 'new_motion'
          #discussion.active_proposal = event.proposal
