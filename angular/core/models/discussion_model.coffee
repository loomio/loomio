angular.module('loomioApp').factory 'DiscussionModel', (DraftableModel, AppConfig) ->
  class DiscussionModel extends DraftableModel
    @singular: 'discussion'
    @plural: 'discussions'
    @uniqueIndices: ['id', 'key']
    @indices: ['groupId', 'authorId']
    @draftParent: 'group'
    @serializableAttributes: AppConfig.permittedParams.discussion

    afterConstruction: ->
      @private = @privateDefaultValue() if @isNew()
      @clientReadSequenceId = @lastReadSequenceId

    defaultValues: =>
      private: null
      usesMarkdown: true
      lastSequenceId: 0
      firstSequenceId: 0
      lastItemAt: null
      title: ''
      description: ''

    privateDefaultValue: =>
      if @group()
        switch @group().discussionPrivacyOptions
          when 'private_only' then true
          when 'public_or_private' then true
          when 'public_only' then false
      else
        null

    relationships: ->
      @hasMany 'comments', sortBy: 'createdAt'
      @hasMany 'events', sortBy: 'sequenceId'
      @hasMany 'proposals', sortBy: 'createdAt', sortDesc: true
      @hasMany 'versions', sortBy: 'createdAt'
      @belongsTo 'group'
      @belongsTo 'author', from: 'users'

    translationOptions: ->
      title:     @title
      groupName: @groupName()

    authorName: ->
      @author().name

    groupName: ->
      @group().name if @group()

    activeProposals: ->
      _.filter @proposals(), (proposal) ->
        proposal.isActive()

    closedProposals: ->
      _.reject @proposals(), (proposal) ->
        proposal.isActive()

    anyClosedProposals: ->
      _.some(@closedProposals())

    activeProposal: ->
      _.first(@activeProposals())

    hasActiveProposal: ->
      @activeProposal()?

    isUnread: ->
      # it is read if we've read it to completion clientside, or if we have no reader
      return false if @readOnClient or !@discussionReaderId?
      !@lastReadAt? or @unreadActivityCount() > 0

    hasUnreadActivity: ->
      @isUnread() && @unreadActivityCount() > 0

    isImportant: ->
      @starred or @hasActiveProposal()

    unreadItemsCount: ->
      @itemsCount - @readItemsCount

    unreadActivityCount: ->
      @salientItemsCount - @readSalientItemsCount

    unreadPosition: ->
      @clientReadSequenceId + 1

    eventIsLoaded: (event) ->
      event.sequenceId or
      _.find @events(), (e) ->
        e.kind == 'new_comment' and e.commentId == event.comment().id

    minLoadedSequenceId: ->
      item = _.min @events(), (event) -> event.sequenceId or Number.MAX_VALUE
      item.sequenceId

    maxLoadedSequenceId: ->
      item = _.max @events(), (event) -> event.sequenceId or 0
      item.sequenceId

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

    saveStar: ->
      @remote.patchMember @keyOrId(), if @starred then 'star' else 'unstar'

    markAsRead: (sequenceId) ->
      return unless @discussionReaderId?
      if isNaN(sequenceId)
        sequenceId = @lastSequenceId
        @update(readItemsCount: @itemsCount,
                readSalientItemsCount: @salientItemsCount,
                readOnClient: @sequenceId == @lastSequenceId,
                lastReadAt: moment())

      if _.isNull(@lastReadAt) or @clientReadSequenceId < sequenceId
        @remote.patchMember(@keyOrId(), 'mark_as_read', {sequence_id: sequenceId})
        @update(lastReadSequenceId: sequenceId, clientReadSequenceId: sequenceId)

    move: =>
      @remote.patchMember @keyOrId(), 'move', { group_id: @groupId }

    edited: ->
      @versionsCount > 1

    attributeForVersion: (attr, version) ->
      return '' unless version
      if version.changes[attr]
        version.changes[attr][1]
      else
        @attributeForVersion(attr, @recordStore.versions.find(version.previousId))
