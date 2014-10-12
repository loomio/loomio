angular.module('loomioApp').factory 'EventModel', (RecordStoreService) ->
  class EventModel
    constructor: (data = {}) ->
      @id = data.id
      @kind = data.kind
      @comment_id = data.comment_id
      @vote_id = data.vote_id

    plural: 'events'

    comment: ->
      RecordStoreService.get('comments', @comment_id)

    vote: ->
      RecordStoreService.get('votes', @vote_id)
