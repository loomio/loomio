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
      @outcome = data.outcome
      @discussionId = data.discussion_id
      @voteCounts = data.vote_counts

    params: ->
      motion:
        id: @id
        discussion_id: @discussionId
        name: @name
        description: @description
        closing_at: @closingAt

    positionVerbs: ['agree', 'abstain', 'disagree', 'block']
    positions: ['yes', 'abstain', 'no', 'block']

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
      !@closedAt?

    uniqueVotesByUserId: ->
      votesByUserId = {}
      _.each _.sortBy(@votes(), 'createdAt'), (vote) ->
        votesByUserId[vote.authorId] = vote
      votesByUserId

    uniqueVotes: ->
      _.values @uniqueVotesByUserId()

    lastVoteByUser: (user) ->
      @uniqueVotesByUserId()[user.id]

    userHasVoted: (user) ->
      @lastVoteByUser(user)?
