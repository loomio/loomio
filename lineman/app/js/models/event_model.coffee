angular.module('loomioApp').factory 'EventModel', (RecordStoreService) ->
  class EventModel
    constructor: (data = {}) ->
      @id = data.id
      @kind = data.kind
      @commentId = data.comment_id
      @discussionId = data.discussion_id
      @proposalId = data.proposal_id
      @voteId = data.vote_id

    plural: 'events'

    discussion: ->
      RecordStoreService.get('discussions', @discussionId)

    comment: ->
      RecordStoreService.get('comments', @commentId)

    proposal: ->
      RecordStoreService.get('proposals', @proposalId)

    vote: ->
      RecordStoreService.get('votes', @voteId)
