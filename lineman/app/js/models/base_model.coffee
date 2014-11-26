angular.module('loomioApp').factory 'BaseModel', (MainRecordStore) ->
  class BaseModel
    constructor: (recordStoreOrData, data) ->
      if data?
        recordStore = recordStoreOrData
      else
        data = recordStoreOrData
        recordStore = MainRecordStore

      Object.defineProperty(@, 'recordStore', value: recordStore, enumerable: false)

      @primaryId = data.id
      @hydrate(data)
      @recordStore[@plural].put(@)

    viewName: -> "#{@plural}-#{@primaryId}"

    isNew: ->
      not @primaryId?

