angular.module('loomioApp').factory 'BaseModel', (MainRecordStore) ->
  class BaseModel
    constructor: (recordStoreOrData, data) ->
      if data?
        @recordStore = recordStoreOrData
      else
        @recordStore = MainRecordStore
        data = recordStoreOrData

      @primaryId = data.id
      @hydrate(data)

    viewName: -> "#{@plural}-#{@primaryId}"

    isNew: ->
      not @primaryId?

