angular.module('loomioApp').factory 'EventModel', (RecordStoreService) ->
  class EventModel
    constructor: (data = {}) ->
      @id = data.id
      @kind = data.kind
      @comment_id = data.comment_id

    plural: 'events'

    comment: ->
      RecordStoreService.get('comments', @comment_id)
