angular.module('loomioApp').factory 'EventModel', (RecordStoreService) ->
  class EventModel
    constructor: (data = {}) ->
      @id = data.id
      @kind = data.kind
      @sequenceId = data.sequence_id
      @commentId = data.comment_id
      @discussionId = data.discussion_id
      @proposalId = data.proposal_id
      @voteId = data.vote_id
      @createdAt = data.created_at
      @actorId = data.actor_id

    plural: 'events'

    destroy: ->
      eventable.destroy()

    eventable: ->
      switch @kind
        when 'new_comment' then @comment()
        when 'new_discussion' then @discussion()
        when 'new_vote' then @vote()
        when 'new_motion' then @proposal()

    discussion: ->
      RecordStoreService.get('discussions', @discussionId)

    comment: ->
      RecordStoreService.get('comments', @commentId)

    proposal: ->
      RecordStoreService.get('proposals', @proposalId)

    vote: ->
      RecordStoreService.get('votes', @voteId)

    actor: ->
      RecordStoreService.get('users', @actorId)

    link: ->
      switch @kind
        when 'comment_liked' then "/discussions/#{@comment().discussion().key}##{@commentId}"
