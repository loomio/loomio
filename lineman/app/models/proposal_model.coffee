angular.module('loomioApp').factory 'ProposalModel', (BaseModel) ->
  class ProposalModel extends BaseModel
    @singular: 'proposal'
    @plural: 'proposals'
    @indices: ['id', 'key', 'discussionId']

    initialize: (data) ->
      @closingAt = moment().add(3, 'days')
      @updateFromJSON(data)

    setupViews: ->
      @setupView 'votes'

    serialize: ->
      motion:
        discussion_id: @discussionId
        name: @name
        description: @description
        closing_at: @closingAt

    positionVerbs: ['agree', 'abstain', 'disagree', 'block']
    positions: ['yes', 'abstain', 'no', 'block']

    closingSoon: ->
      @isActive() and @closingAt < moment().add(24, 'hours').toDate()

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
      !@closedAt?

    isClosed: ->
      !@isActive()

    uniqueVotesByUserId: ->
      votesByUserId = {}
      _.each _.sortBy(@votes(), 'createdAt'), (vote) ->
        votesByUserId[vote.authorId] = vote
      votesByUserId

    uniqueVotes: ->
      _.values @uniqueVotesByUserId()

    numberVoted: ->
      @uniqueVotes().length

    percentVoted: ->
      numVoted = @numberVoted()
      groupSize = @groupSizeWhenVoting()
      return 0 if numVoted == 0 or groupSize == 0
      numVoted / groupSize * 100

    groupSizeWhenVoting: ->
      if @isActive()
        @group().membersCount
      else
        @numberVoted() + parseInt(@didNotVotesCount)

    lastVoteByUser: (user) ->
      @uniqueVotesByUserId()[user.id]

    userHasVoted: (user) ->
      @lastVoteByUser(user)?

    close: ->
      @restfulClient.postMember(@id, "close")

    hasOutcome: ->
      _.some(@outcome)
