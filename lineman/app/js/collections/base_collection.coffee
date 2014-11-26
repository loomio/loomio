angular.module('loomioApp').factory 'BaseCollection', ->
  class BaseCollection
    constructor: (db) ->
      @db = db
      @collection = @db.addCollection(@collectionName)

    find: (args) ->
      @collection.find(args)

    chain: () ->
      @collection.chain()

    get: (q) ->
      if q?
        if _.isNumber(q)
          @collection.find(primaryId: q)[0]
        else if _.isString(q)
          @collection.find(key: q)[0]
        else if _.isArray(q)
          if q.length == 0
            []
          else if _.isString(q[0])
            @collection.find(key: {$in: q})
          else if _.isNumber(q[0])
            @collection.find(primaryId: {$in: q})
      else
        @collection.find()

    put: (record) ->
      @collection.insert(record)

    remove: (record) ->
      @collection.remove(record)

    belongingTo: (record, options = {}) ->
      foreignKey = options.foreignKey if _.has(options, 'foreignKey')

      view = @collection.addDynamicView("#{record.plural}-#{record.primaryId}")
      obj = {}
      obj[record.foreignKey] = record.primaryId
      view.applyFind(obj)
