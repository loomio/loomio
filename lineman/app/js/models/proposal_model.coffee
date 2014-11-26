angular.module('loomioApp').factory 'ProposalModel', (BaseModel) ->
  class ProposalModel extends BaseModel
    plural: 'proposals'

    hydrate: (data) ->
      @name = data.name
      @description = data.description
      @createdAt = data.created_at
      @closingAt = data.closing_at
      @closedAt = data.closed_at
      @authorId = data.author_id
      @outcome = data.outcome
      @discussionId = data.discussion_id
      @voteCounts = data.vote_counts
      @activityCount = data.activity_count

    params: ->
      motion:
        id: @primaryId
        discussion_id: @discussionId
        name: @name
        description: @description
        closing_at: @closingAt

    positionVerbs: ['agree', 'abstain', 'disagree', 'block']
    positions: ['yes', 'abstain', 'no', 'block']


    author: ->
      @recordStore.users.get(@authorId)

    discussion: ->
      @recordStore.discussions.get(@discussionId)

    votes: ->
      @recordStore.votes.find(proposalId: @primaryId)

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
