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

    # update: (attributes) =>
    #   @baseUpdate(attributes)
    #   # find pollOptions not in @pollOptionIds and destroy
    #   _.each @pollOptions(), (pollOption) =>
    #     pollOption.remove() unless _.includes(@pollOptionIds, pollOption.id)
    #     true
      

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

    close: =>
      @remote.postMember(@id, 'close')
