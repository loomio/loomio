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
      pollOptionsAttributes: []

    relationships: ->
      @belongsTo 'author', from: 'users'
      @belongsTo 'discussion'
      @hasMany   'pollOptions'
      @hasMany   'stances'

    outcome: ->
      @recordStore.outcomes.find(pollId: @id)[0]

    uniqueStances: ->
      _.values @uniqueStancesByUserId()

    lastStanceByUser: (user) ->
      @uniqueStancesByUserId()[user.id]

    userHasVoted: (user) ->
      @lastStanceByUser(user)?

    uniqueStancesByUserId: ->
      stancesByUserId = {}
      _.each _.sortBy(@stances(), 'createdAt'), (stance) ->
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

    close: =>
      @remote.postMember(@id, 'close')
