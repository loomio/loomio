angular.module('loomioApp').factory 'DiscussionModel', (DraftableModel, AppConfig) ->
  class DiscussionModel extends DraftableModel
    @singular: 'discussion'
    @plural: 'discussions'
    @uniqueIndices: ['id', 'key']
    @indices: ['groupId', 'authorId']
    @draftParent: 'group'
    @draftPayloadAttributes: ['title', 'description']
    @serializableAttributes: AppConfig.permittedParams.discussion

    afterConstruction: ->
      @private = @privateDefaultValue() if @isNew()
      @newAttachmentIds = _.clone(@attachmentIds) or []

    defaultValues: =>
      private: null
      usesMarkdown: true
      lastSequenceId: 0
      firstSequenceId: 0
      lastItemAt: null
      title: ''
      description: ''

    serialize: ->
      data = @baseSerialize()
      data.discussion.attachment_ids = @newAttachmentIds
      data

    privateDefaultValue: =>
      return true unless @group()
      @group().discussionPrivacyOptions != 'public_only'

    relationships: ->
      @hasMany 'comments', sortBy: 'createdAt'
      @hasMany 'events', sortBy: 'sequenceId'
      @hasMany 'polls', sortBy: 'createdAt', sortDesc: true
      @hasMany 'versions', sortBy: 'createdAt'
      @belongsTo 'group'
      @belongsTo 'guestGroup', from: 'groups'
      @belongsTo 'author', from: 'users'

    reactions: ->
      @recordStore.reactions.find(reactableId: @id, reactableType: "Discussion")

    translationOptions: ->
      title:     @title
      groupName: @groupName()

    authorName: ->
      @author().name if @author()

    groupName: ->
      @group().name if @group()

    activePolls: ->
      _.filter @polls(), (poll) ->
        poll.isActive()

    hasActivePoll: ->
      _.any @activePolls()

    hasDecision: ->
      @hasActivePoll()

    closedPolls: ->
      _.filter @polls(), (poll) ->
        !poll.isActive()

    activePoll: ->
      _.first @activePolls()

    isUnread: ->
      !@isDismissed() and
      @discussionReaderId? and (!@lastReadAt? or @unreadActivityCount() > 0)

    isDismissed: ->
      @discussionReaderId? and @dismissedAt? and @dismissedAt.isSameOrAfter(@lastActivityAt)

    hasUnreadActivity: ->
      @isUnread() && @unreadActivityCount() > 0

    hasDescription: ->
      !!@description

    unreadActivityCount: ->
      @salientItemsCount - @readSalientItemsCount

    requireReloadFor: (event) ->
      return false if !event or event.discussionId != @id or event.sequenceId
      _.find @events(), (e) -> e.kind == 'new_comment' and e.eventable.id == event.eventable.id

    minLoadedSequenceId: ->
      item = _.min @events(), (event) -> event.sequenceId or Number.MAX_VALUE
      item.sequenceId

    maxLoadedSequenceId: ->
      item = _.max @events(), (event) -> event.sequenceId or 0
      item.sequenceId

    allEventsLoaded: ->
      @recordStore.events.find(discussionId: @id).length == @itemsCount

    membership: ->
      @recordStore.memberships.find(userId: AppConfig.currentUserId, groupId: @groupId)[0]

    membershipVolume: ->
      @membership().volume if @membership()

    volume: ->
      @discussionReaderVolume or @membershipVolume()

    saveVolume: (volume, applyToAll = false) =>
      if applyToAll
        @membership().saveVolume(volume)
      else
        @discussionReaderVolume = volume if volume?
        @remote.patchMember @keyOrId(), 'set_volume', { volume: @discussionReaderVolume }

    isMuted: ->
      @volume() == 'mute'

    update: (attrs) ->
      delete attrs.lastReadSequenceId    if attrs.lastReadSequenceId < @lastReadSequenceId
      delete attrs.readSalientItemsCount if attrs.readSalientItemsCount < @readSalientItemsCount
      @baseUpdate(attrs)

    markAsSeen: ->
      return unless @discussionReaderId and !@lastReadAt
      @remote.patchMember @keyOrId(), 'mark_as_seen'
      @update(lastReadAt: moment(), lastReadSequenceId: 0)

    dismiss: ->
      @remote.patchMember @keyOrId(), 'dismiss'
      @update(dismissedAt: moment())

    move: =>
      @remote.patchMember @keyOrId(), 'move', { group_id: @groupId }

    savePin: =>
      @remote.patchMember @keyOrId(), 'pin'

    edited: ->
      @versionsCount > 1

    newAttachments: ->
      @recordStore.attachments.find(@newAttachmentIds)

    attachments: ->
      @recordStore.attachments.find(attachableId: @id, attachableType: 'Discussion')

    hasAttachments: ->
      _.some @attachments()

    attributeForVersion: (attr, version) ->
      return '' unless version
      if version.changes[attr]
        version.changes[attr][1]
      else
        @attributeForVersion(attr, @recordStore.versions.find(version.previousId))

    cookedDescription: ->
      cooked = @description
      _.each @mentionedUsernames, (username) ->
        cooked = cooked.replace(///@#{username}///g, "[[@#{username}]]")
      cooked
