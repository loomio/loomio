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
      @hasMany   'communities'
      @hasMany   'visitors'

    group: ->
      if @discussion()
        @discussion().group()
      else
        @recordStore.groups.find(@groupId)

    userVoters: ->
      @recordStore.users.find(_.pluck(@stances(), 'userId'))

    visitorVoters: ->
      @recordStore.visitors.find(_.pluck(@stances(), 'visitorId'))

    newAttachments: ->
      @recordStore.attachments.find(@newAttachmentIds)

    attachments: ->
      @recordStore.attachments.find(attachableId: @id, attachableType: 'Poll')

    hasAttachments: ->
      _.some @attachments()

    communitySize: ->
      @membersCount() + (@visitorsCount || 0)

    membersCount: ->
      if @group()
        @group().membershipsCount
      else
        1 # <-- this is the author

    announcementSize: (action) ->
      switch action or @notifyAction()
        when 'publish' then @communitySize()
        when 'edit'    then @stancesCount
        else                0

    percentVoted: ->
      (100 * @stancesCount / @communitySize()).toFixed(0) if @communitySize() > 0

    undecidedCount: ->
      @undecidedUserCount + @undecidedVisitorCount

    undecidedUsers: ->
      if @isActive()
        if @group()
          _.difference(@group().members(), @userVoters())
        else
          _.difference([@author()], @userVoters())
      else
        @recordStore.users.find(_.pluck(@pollDidNotVotes(), 'userId'))

    undecidedVisitors: ->
      _.difference(@visitors(), @visitorVoters())

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

    cookedDetails: ->
      MentionLinkService.cook(@mentionedUsernames, @details)

    isActive: ->
      !@closedAt?

    isClosed: ->
      @closedAt?

    goal: ->
      @customFields.goal or @communitySize()

    close: =>
      @remote.postMember(@key, 'close')

    publish: (community, message) =>
      @remote.postMember(@key, 'publish', community_id: community.id, message: message).then =>
        @published = true

    addOptions: =>
      @remote.postMember(@key, 'add_options', poll_option_names: @pollOptionNames)

    createVisitors: ->
      @processing = true
      @remote.postMember(@key, 'create_visitors', emails: @customFields.pending_emails.join(',')).finally =>
        @processing = false

    toggleSubscription: =>
      @remote.postMember(@key, 'toggle_subscription')

    enableCommunities: ->
      (@group() and @group().features.enable_communities) or
      (@author() and @author().experiences.enable_communities)

    notifyAction: ->
      if @isNew()
        'publish'
      else
        'edit'
