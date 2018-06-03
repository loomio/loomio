Loki        = require 'lokijs'
LokiAdapter = require 'lokijs/src/loki-indexed-adapter'

module.exports =
  autoloadDatabase: (records) ->
    cached = new Loki 'loomio.db',
      adapter: new LokiAdapter()
      autoload: true
      autoloadCallback: ->
        records.import cachedRecords(cached), skipSave: true

cachedRecords = (db) ->
  _.reduce db.collections, (result, coll) ->
    if coll.data.length
      result[_.camelCase(coll.name)] = coll.data.map (record) ->
        _.pick record, record.attributeNames
    result
  , {}
