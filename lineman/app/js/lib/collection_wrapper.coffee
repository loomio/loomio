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
      existingRecord = @collection.find(id: data.id)[0]
      if data.id? and existingRecord?
        existingRecord.initialize(data)
        existingRecord
      else
        record = new @model(@recordStore, data)
        @collection.insert(record) if data.id?
        record

    findById: (id) ->
      @collection.find(id: id)[0]

    findByKey: (key) ->
      @collection.find(key: key)[0]

    findByIds: (ids) ->
      @collection.find(id: {'$in': ids})

    findByKeys: (keys) ->
      @collection.find(key: {'$in': keys})

    get: (q, debug = false) ->
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
        'weird input'

    remove: (record) ->
      @collection.remove(record)

    belongingTo: (record, options = {}) ->
      foreignKey = options.foreignKey if _.has(options, 'foreignKey')

      view = @collection.addDynamicView("#{record.plural}-#{record.id}")
      obj = {}
      obj[record.foreignKey] = record.id
      view.applyFind(obj)
