angular.module('loomioApp').factory 'EventModel', (RecordStoreService) ->
  class EventModel
    constructor: (data = {}) ->
      @id = data.id
      @kind = data.kind
      @comment_id = data.comment_id
      @proposal_id = data.proposal_id
      @vote_id = data.vote_id

    plural: 'events'

    comment: ->
      RecordStoreService.get('comments', @comment_id)

    proposal: ->
      RecordStoreService.get('proposals', @proposal_id)

    vote: ->
      RecordStoreService.get('votes', @vote_id)
