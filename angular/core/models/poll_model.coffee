angular.module('loomioApp').factory 'PollModel', (DraftableModel, AppConfig, MentionLinkService) ->
  class PollModel extends DraftableModel
    @singular: 'poll'
    @plural: 'polls'
    @indices: ['discussionId', 'authorId']
    @serializableAttributes: AppConfig.permittedParams.poll
    @draftParent: 'draftParent'
    @draftPayloadAttributes: ['title', 'details']

    draftParent: ->
      @discussion() or @author()

    afterConstruction: ->
      @newAttachmentIds = _.clone(@attachmentIds) or []
      @customFields.dots_per_person = 8 if @pollType == 'dot_vote'

    # the polls which haven't closed have the highest importance
    # (and so have the lowest value here)
    # Both are sorted by distance from the current time
    # (IE, polls which have closed or will close closest to now are most important)
    importance: (now) ->
      if @closedAt?
        Math.abs(@closedAt - now)
      else
        0.0001 * Math.abs(@closingAt - now)

    defaultValues: ->
      discussionId: null
      title: ''
      details: ''
      closingAt: moment().add(3, 'days').startOf('hour')
      pollOptionNames: []
      pollOptionIds: []
      customFields: {}

    serialize: ->
      data = @baseSerialize()
      data.poll.attachment_ids = @newAttachmentIds
      data

    relationships: ->
      @belongsTo 'author', from: 'users'
      @belongsTo 'discussion'
      @hasMany   'pollOptions'
      @hasMany   'stances', sortBy: 'createdAt', sortDesc: true
      @hasMany   'pollDidNotVotes'

    group: ->
      @discussion().group() if @discussion()

    voters: ->
      @recordStore.users.find(_.pluck(@stances(), 'userId'))

    newAttachments: ->
      @recordStore.attachments.find(@newAttachmentIds)

    attachments: ->
      @recordStore.attachments.find(attachableId: @id, attachableType: 'Poll')

    hasAttachments: ->
      _.some @attachments()

    communitySize: ->
      if @group()
        @group().membershipsCount
      else
        0

    percentVoted: ->
      (100 * @stancesCount / @communitySize()).toFixed(0) if @communitySize() > 0

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

    clearStaleStances: ->
      existing = []
      _.each @uniqueStances('-createdAt'), (stance) ->
        if _.contains(existing, stance.participant())
          stance.remove()
        else
          existing.push(stance.participant())

    uniqueStances: (order, limit) ->
      _.slice(_.sortBy(@recordStore.stances.find(pollId: @id, latest: true), order), 0, limit)

    group: ->
      @discussion().group() if @discussion()

    cookedDetails: ->
      MentionLinkService.cook(@mentionedUsernames, @details)

    isActive: ->
      !@closedAt?

    isClosed: ->
      @closedAt?

    goal: ->
      @customFields.goal or @communitySize()

    close: =>
      @remote.postMember(@id, 'close')
