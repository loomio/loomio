angular.module('loomioApp').factory 'ProposalModel', (BaseModel) ->
  class ProposalModel extends BaseModel
    @singular: 'proposal'
    @plural: 'proposals'

    initialize: (data) ->
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
      @activityCount = data.activity_count

    setupViews: ->
      @votesView = @recordStore.votes.collection.addDynamicView(@viewName())
      @votesView.applyFind(proposalId: @id)
      @votesView.applySimpleSort('id')

    serialize: ->
      motion:
        discussion_id: @discussionId
        name: @name
        description: @description
        closing_at: @closingAt

    positionVerbs: ['agree', 'abstain', 'disagree', 'block']
    positions: ['yes', 'abstain', 'no', 'block']

    canBeEdited: ->
      @isNew() or !@hasVotes()

    hasVotes: ->
      @votes().length > 0

    author: ->
      @recordStore.users.find(@authorId)

    group: ->
      @discussion().group()

    discussion: ->
      @recordStore.discussions.find(@discussionId)

    votes: ->
      @votesView.data() unless @isNew()

    authorName: ->
      @author().name

    isActive: ->
      !(@closedAt?)

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

    close: ->
      @processing = true
      @restfulClient.postMember(@id, "close").then(@saveSuccess, @saveFailure)
