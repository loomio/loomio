angular.module('loomioApp').factory 'CollectionWrapper', ->
  class CollectionWrapper
    constructor: (recordStore, collection, model) ->
      @recordStore = recordStore
      @collection = collection
      @model = model

    find: (args) ->
      @collection.find(args)

    addDynamicView: (name) ->
      @collection.addDynamicView(name)

    chain: () ->
      @collection.chain()

    new: (data) ->
      new @model(@recordStore, data)

    get: (q) ->
      if q?
        if _.isNumber(q)
          @collection.find(id: q)[0]
        else if _.isString(q)
          @collection.find(key: q)[0]
        else if _.isArray(q)
          if q.length == 0
            []
          else if _.isString(q[0])
            @collection.find(key: {$in: q})
          else if _.isNumber(q[0])
            @collection.find(id: {$in: q})
      else
        @collection.find()

    put: (record) ->
      @collection.insert(record)

    remove: (record) ->
      @collection.remove(record)

    belongingTo: (record, options = {}) ->
      foreignKey = options.foreignKey if _.has(options, 'foreignKey')

      view = @collection.addDynamicView("#{record.plural}-#{record.id}")
      obj = {}
      obj[record.foreignKey] = record.id
      view.applyFind(obj)
