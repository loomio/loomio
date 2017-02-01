angular.module('loomioApp').factory 'PollModel', (DraftableModel, AppConfig, MentionLinkService) ->
  class PollModel extends DraftableModel
    @singular: 'poll'
    @plural: 'polls'
    @indices: ['discussionId', 'authorId']
    @serializableAttributes: AppConfig.permittedParams.poll
    @draftParent: 'discussion'

    defaultValues: ->
      discussionId: null
      title: ''
      details: ''
      closingAt: moment().add(3, 'days').startOf('hour')
      pollOptionNames: []
      pollOptionIds: []

    relationships: ->
      @belongsTo 'author', from: 'users'
      @belongsTo 'discussion'
      @hasMany   'pollOptions'
      @hasMany   'stances', sortBy: 'createdAt', sortDesc: true
      @hasMany   'pollDidNotVotes'

    group: ->
      @discussion().group() if @discussion()

    voters: ->
      @recordStore.users.find(_.pluck(@stances(), 'participantId'))

    communitySize: ->
      if @group()
        @group().membershipsCount
      else
        0

    undecidedCount: ->
      if @isActive()
        _.max [@communitySize() - @stancesCount, 0]
      else
        @didNotVotesCount

    undecidedMembers: ->
      if @isActive()
        _.difference(@group().members(), @voters())
      else
        @recordStore.users.find(_.pluck(@pollDidNotVotes(), 'userId'))

    firstOption: ->
      _.first @pollOptions()

    outcome: ->
      @recordStore.outcomes.find(pollId: @id, latest: true)[0]

    uniqueStances: (order, limit) ->
      _.slice(_.sortBy(_.values(@uniqueStancesByUserId()), order), 0, limit)

    stanceFor: (user) ->
      @uniqueStancesByUserId()[user.id]

    lastStanceByUser: (user) ->
      @uniqueStancesByUserId()[user.id]

    userHasVoted: (user) ->
      @lastStanceByUser(user)?

    uniqueStancesByUserId: ->
      stancesByUserId = {}
      _.each @stances(), (stance) ->
        stancesByUserId[stance.participantId] = stancesByUserId[stance.participantId] or stance
      stancesByUserId

    group: ->
      @discussion().group() if @discussion()

    cookedDetails: ->
      MentionLinkService.cook(@mentionedUsernames, @details)

    isActive: ->
      !@closedAt?

    goal: ->
      @customFields.goal or @communitySize()

    close: =>
      @remote.postMember(@id, 'close')
