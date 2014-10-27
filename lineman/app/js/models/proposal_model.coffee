angular.module('loomioApp').factory 'ProposalModel', (RecordStoreService) ->
  class ProposalModel
    constructor: (data = {}) ->
      @id = data.id
      @name = data.name
      @description = data.description
      @createdAt = data.created_at
      @closingAt = data.closing_at
      @closedAt = data.closed_at
      @authorId = data.author_id
      @discussionId = data.discussion_id
      #@voteIds = data.vote_ids
      @voteCounts = data.vote_counts

    params: ->
      id: @id
      discussion_id: @discussionId
      name: @name
      description: @description
      closing_at: @closingAt

    plural: 'proposals'

    author: ->
      RecordStoreService.get('users', @authorId)

    discussion: ->
      RecordStoreService.get('discussions', @discussionId)

    votes: ->
      RecordStoreService.get 'votes', (vote) =>
        vote.proposalId == @id

    authorName: ->
      @author().name

    isActive: ->
      @closedAt == null

    userHasVoted: (user) ->
      _.any @votes(), (vote) ->
        vote.authorId == user.id

    votesSortedByCreatedAt: ->
      _.sortBy @votes(), (vote) -> moment(vote.createdAt).unix()

    votesByUser: (user) ->
      _.filter @votesSortedByCreatedAt(), (vote) ->
        vote.authorId == user.id

    lastVoteByUser: (user) ->
      _.last(@votesByUser(user))

