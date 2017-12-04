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

    poll: -> @

    documents: ->
      @recordStore.documents.find(modelId: @id, modelType: "Poll")

    hasDocuments: ->
      @documents().length > 0

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
      @belongsTo 'group'
      @belongsTo 'guestGroup', from: 'groups'
      @hasMany   'pollOptions'
      @hasMany   'stances', sortBy: 'createdAt', sortDesc: true
      @hasMany   'pollDidNotVotes'

    reactions: ->
      @recordStore.reactions.find(reactableId: @id, reactableType: "Poll")

    newAttachments: ->
      @recordStore.attachments.find(@newAttachmentIds)

    attachments: ->
      @recordStore.attachments.find(attachableId: @id, attachableType: 'Poll')

    hasAttachments: ->
      _.some @attachments()

    announcementSize: (action) ->
      return @group().announcementRecipientsCount if @group() and @isNew()
      switch action or @notifyAction()
        when 'publish' then @stancesCount + @undecidedUserCount
        when 'edit'    then @stancesCount
        else                0

    memberIds: ->
      _.uniq if @isActive()
        @formalMemberIds().concat @guestIds()
      else
        @participantIds().concat @undecidedIds()

    formalMemberIds: ->
      # TODO: membersCanVote
      if @group() then @group().memberIds() else []

    guestIds: ->
      if @guestGroup() then @guestGroup().memberIds() else []

    participantIds: ->
      _.pluck(@latestStances(), 'participantId')

    undecidedIds: ->
      _.pluck(@pollDidNotVotes(), 'userId')

    # who can vote?
    members: ->
      @recordStore.users.find(@memberIds())

    # who's voted?
    participants: ->
      @recordStore.users.find(@participantIds())

    # who hasn't voted?
    undecided: ->
      _.difference(@members(), @participants())

    membersCount: ->
      # NB: this won't work for people who vote, then leave the group.
      @stancesCount + @undecidedCount

    percentVoted: ->
      return 0 if @membersCount() == 0
      (100 * @stancesCount / (@membersCount())).toFixed(0)

    outcome: ->
      @recordStore.outcomes.find(pollId: @id, latest: true)[0]

    clearStaleStances: ->
      existing = []
      _.each @latestStances('-createdAt'), (stance) ->
        if _.contains(existing, stance.participant())
          stance.latest = false
        else
          existing.push(stance.participant())

    latestStances: (order, limit) ->
      _.slice(_.sortBy(@recordStore.stances.find(pollId: @id, latest: true), order), 0, limit)

    cookedDetails: ->
      MentionLinkService.cook(@mentionedUsernames, @details)

    cookedDescription: ->
      @cookedDetails()

    hasDescription: ->
      !!@details

    isActive: ->
      !@closedAt?

    isClosed: ->
      @closedAt?

    goal: ->
      @customFields.goal or @membersCount().length

    close: =>
      @remote.postMember(@key, 'close')

    addOptions: =>
      @remote.postMember(@key, 'add_options', poll_option_names: @pollOptionNames)

    inviteGuests: ->
      @processing = true
      @remote.postMember(@key, 'invite_guests', emails: @customFields.pending_emails.join(',')).finally =>
        @processing = false

    toggleSubscription: =>
      @remote.postMember(@key, 'toggle_subscription')

    notifyAction: ->
      if @isNew()
        'publish'
      else
        'edit'

    removeOrphanOptions: ->
      _.each @pollOptions(), (option) =>
        option.remove() unless _.includes(@pollOptionNames, option.name)
