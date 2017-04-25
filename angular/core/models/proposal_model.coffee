angular.module('loomioApp').factory 'ProposalModel', (BaseModel, AppConfig, DraftableModel) ->
  class ProposalModel extends DraftableModel
    @singular: 'proposal'
    @plural: 'proposals'
    @uniqueIndices: ['id', 'key']
    @indices: ['discussionId']
    @serializationRoot: 'motion'
    @serializableAttributes: AppConfig.permittedParams.motion
    @draftParent: 'discussion'
    @draftPayloadAttributes: ['name', 'description']

    afterConstruction: ->
      @newAttachmentIds = _.clone(@attachmentIds) or []

    defaultValues: ->
      description: ''
      outcome: ''
      voteCounts: {yes: 0, no: 0, abstain: 0, block: 0}
      closingAt: moment().add(3, 'days').startOf('hour')

    serialize: ->
      data = @baseSerialize()
      data.motion.attachment_ids = @newAttachmentIds
      data

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
      return 0 if @votersCount == 0 or @membersCount == 0
      (100 * @votersCount / @membersCount).toFixed(0)

    lastVoteByUser: (user) ->
      @uniqueVotesByUserId()[user.id]

    userHasVoted: (user) ->
      @lastVoteByUser(user)?

    close: =>
      @remote.postMember(@id, "close")

    hasOutcome: ->
      _.some(@outcome)

    hasContext: ->
      !!@description

    undecidedMembers: ->
      if @isActive()
        _.difference(@group().members(), @voters())
      else
        @recordStore.users.find(_.pluck(@didNotVotes(), 'userId'))

    undecidedUsernames: ->
      _.pluck(@undecidedMembers(), 'username')

    hasUndecidedMembers: ->
      @membersCount > @votersCount

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

    cookedDescription: ->
      cooked = @description
      _.each @mentionedUsernames, (username) ->
        cooked = cooked.replace(///@#{username}///g, "[[@#{username}]]")
      cooked

    newAttachments: ->
      @recordStore.attachments.find(@newAttachmentIds)

    attachments: ->
      @recordStore.attachments.find(attachableId: @id, attachableType: 'Motion')
