angular.module('loomioApp').factory 'RecordStore', (CollectionWrapper) ->
  class RecordStore
    constructor: (db) ->
      @db = db

    addCollection: (model) ->
      unwrappedCollection = @db.addCollection(model.plural)
      collection = @[model.plural] = new CollectionWrapper(@, unwrappedCollection, model)
      collection

