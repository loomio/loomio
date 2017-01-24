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
      @hasMany   'stances'

    group: ->
      @discussion().group() if @discussion()

    communitySize: ->
      if @group()
        @group().membershipsCount
      else
        0

    firstOption: ->
      _.first @pollOptions()

    outcome: ->
      @recordStore.outcomes.find(pollId: @id)[0]

    uniqueStances: (order, limit) ->
      _.slice(_.sortBy(_.values(@uniqueStancesByUserId()), order), 0, limit)

    lastStanceByUser: (user) ->
      @uniqueStancesByUserId()[user.id]

    userHasVoted: (user) ->
      @lastStanceByUser(user)?

    uniqueStancesByUserId: ->
      stancesByUserId = {}
      _.each @stances(), (stance) ->
        stancesByUserId[stance.participantId] = stance
      stancesByUserId

    stanceFor: (user) ->
      @uniqueStancesByUserId()[user.id]

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
