angular.module('loomioApp').factory 'ProposalModel', (BaseModel, AppConfig, DraftableModel) ->
  class ProposalModel extends DraftableModel
    @singular: 'proposal'
    @plural: 'proposals'
    @uniqueIndices: ['id', 'key']
    @indices: ['discussionId']
    @serializationRoot: 'motion'
    @serializableAttributes: AppConfig.permittedParams.motion
    @draftParent: 'discussion'

    defaultValues: ->
      voteCounts: {yes: 0, no: 0, abstain: 0, block: 0}
      closingAt: moment().add(3, 'days').startOf('hour')

    relationships: ->
      @hasMany 'votes', sortBy: 'createdAt', sortDesc: true
      @hasMany 'didNotVotes'
      @belongsTo 'author', from: 'users'
      @belongsTo 'discussion'

    positionVerbs: ['agree', 'abstain', 'disagree', 'block']
    positions: ['yes', 'abstain', 'no', 'block']

    closingSoon: ->
      @isActive() and @closingAt < moment().add(24, 'hours').toDate()

    canBeEdited: ->
      @isNew() or !@hasVotes()

    hasVotes: ->
      @votes().length > 0

    group: ->
      @discussion().group()

    voters: ->
      @recordStore.users.find(@voterIds())

    voterIds: ->
      _.pluck(@votes(), 'authorId')

    authorName: ->
      @author().name

    isActive: ->
      !@isClosed()

    isClosed: ->
      @closedAt? or (@closingAt? and @closingAt.isBefore())

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
        @group().membershipsCount
      else
        @numberVoted() + parseInt(@didNotVotesCount)

    lastVoteByUser: (user) ->
      @uniqueVotesByUserId()[user.id]

    userHasVoted: (user) ->
      @lastVoteByUser(user)?

    close: =>
      @remote.postMember(@id, "close")

    hasOutcome: ->
      _.some(@outcome)

    undecidedMembers: ->
      if @isActive()
        _.difference(@group().members(), @voters())
      else
        @recordStore.users.find(_.pluck(@didNotVotes(), 'userId'))

    hasUndecidedMembers: ->
      @membersNotVotedCount > 0

    createOutcome: =>
      @remote.postMember @id, "create_outcome",
        motion:
          outcome: @outcome

    updateOutcome: =>
      @remote.postMember @id, "update_outcome",
        motion:
          outcome: @outcome

    fetchUndecidedMembers: ->
      if @isActive()
        @recordStore.memberships.fetchByGroup(@group().key, {per: 500})
      else
        @recordStore.didNotVotes.fetchByProposal(@key, {per: 500})
