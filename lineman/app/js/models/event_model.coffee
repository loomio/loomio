angular.module('loomioApp').factory 'EventModel', (BaseModel) ->
  class EventModel extends BaseModel
    @singular: 'event'
    @plural: 'events'
    @foreignKey: 'eventId'

    initialize: (data) ->
      @id = data.id
      @kind = data.kind
      @sequenceId = data.sequence_id
      @commentId = data.comment_id
      @discussionId = data.discussion_id
      @proposalId = data.proposal_id
      @membershipRequestId = data.membership_request_id
      @voteId = data.vote_id
      @createdAt = data.created_at
      @actorId = data.actor_id

    serialize: ->
      # commented out because it looks mental
      #switch @kind
        #when 'new_comment' then @comment()
        #when 'new_discussion' then @discussion()
        #when 'new_vote' then @vote()
        #when 'new_motion' then @proposal()

    membershipRequest: ->
      @recordStore.membership_requests.find(@membershipRequestId)

    discussion: ->
      @recordStore.discussions.find(@discussionId)

    comment: ->
      @recordStore.comments.find(@commentId)

    proposal: ->
      @recordStore.proposals.find(@proposalId)

    vote: ->
      @recordStore.votes.find(@voteId)

    actor: ->
      @recordStore.users.find(@actorId)

    link: ->
      switch @kind
        when 'comment_liked' then "/discussions/#{@comment().discussion().key}##{@commentId}"
