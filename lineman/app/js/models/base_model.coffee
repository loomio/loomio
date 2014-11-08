angular.module('loomioApp').factory 'BaseModel', (RecordStoreService) ->
  class BaseModel
    isNew: ->
      not @id?

    key_or_id: ->
      if @key?
        @key
      else
        @id

