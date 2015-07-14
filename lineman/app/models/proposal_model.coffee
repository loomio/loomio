angular.module('loomioApp').factory 'ProposalModel', (BaseModel) ->
  class ProposalModel extends BaseModel
    @singular: 'proposal'
    @plural: 'proposals'
    @indices: ['id', 'key', 'discussionId']

    defaultValues: ->
      voteCounts: {yes: 0, no: 0, abstain: 0, block: 0}
      closingAt: moment().add(3, 'days')

    setupViews: ->
      @setupView 'votes'
      @setupView 'didNotVotes'

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

    didNotVotes: ->
      @didNotVotesView.data() unless @isNew()

    voters: ->
      @recordStore.users.find(@voterIds())

    voterIds: ->
      _.pluck(@votes(), 'authorId')

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
      (100 * numVoted / groupSize).toFixed(0)

    groupSizeWhenVoting: ->
      if @isActive()
        @group().membersCount
      else
        @numberVoted() + parseInt(@didNotVotesCount)

    lastVoteByUser: (user) ->
      @uniqueVotesByUserId()[user.id]

    userHasVoted: (user) ->
      @lastVoteByUser(user)?

    close: =>
      @restfulClient.postMember(@id, "close")

    hasOutcome: ->
      _.some(@outcome)

    undecidedMembers: ->
      if @isActive()
        _.difference(@group().members(), @voters())
      else
        @recordStore.users.find(_.pluck(@didNotVotes(), 'userId'))
