angular.module('loomioApp').factory 'BaseModel', (RecordStoreService) ->
  class BaseModel
    key_or_id: ->
      if @key?
        @key
      else
        @id

