angular.module('loomioApp').factory 'DiscussionModel', (DraftableModel, AppConfig) ->
  class DiscussionModel extends DraftableModel
    @singular: 'discussion'
    @plural: 'discussions'
    @uniqueIndices: ['id', 'key']
    @indices: ['groupId', 'authorId']
    @draftParent: 'group'
    @serializableAttributes: AppConfig.permittedParams.discussion

    afterConstruction: ->
      if @isNew()
        @private = @privateDefaultValue()

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

    activeProposalClosingAt: ->
      proposal = @activeProposal()
      proposal.closingAt if proposal?

    activeProposalClosedAt: ->
      proposal = @activeProposal()
      proposal.closedAt if proposal?

    activeProposalLastVoteAt: ->
      proposal = @activeProposal()
      proposal.lastVoteAt if proposal?

    isUnread: ->
      @discussionReaderId? and (!@lastReadAt? or @unreadActivityCount() > 0)

    isImportant: ->
      @starred or @hasActiveProposal()

    unreadItemsCount: ->
      @itemsCount - @readItemsCount

    unreadActivityCount: ->
      @salientItemsCount - @readSalientItemsCount

    unreadCommentsCount: ->
      @commentsCount - @readCommentsCount

    lastInboxActivity: ->
      @activeProposalClosingAt() or @lastActivityAt

    unreadPosition: ->
      @lastReadSequenceId + 1

    minLoadedSequenceId: ->
      item = _.min @events(), (event) -> event.sequenceId or Number.MAX_VALUE
      item.sequenceId

    maxLoadedSequenceId: ->
      item = _.max @events(), (event) -> event.sequenceId or 0
      item.sequenceId

    membershipVolume: ->
      membership = @recordStore.memberships.find(userId: AppConfig.currentUserId, groupId: @groupId)[0]
      membership.volume if membership

    volume: ->
      @discussionReaderVolume or @membershipVolume()

    changeVolume: =>
      @remote.patchMember @keyOrId(), 'set_volume', { volume: @discussionReaderVolume }

    isMuted: ->
      @volume() == 'mute'

    saveStar: ->
      @remote.patchMember @keyOrId(), if @starred then 'star' else 'unstar'

    markAsRead: (sequenceId) ->
      if isNaN(sequenceId)
        sequenceId = @lastSequenceId
        @update(readItemsCount: @itemsCount,
                readSalientItemsCount: @salientItemsCount,
                readCommentsCount: @commentsCount,
                lastReadAt: moment())

      if _.isNull(@lastReadAt) or @lastReadSequenceId < sequenceId
        @remote.patchMember(@keyOrId(), 'mark_as_read', {sequence_id: sequenceId})
        @lastReadSequenceId = sequenceId

    move: =>
      @remote.patchMember @keyOrId(), 'move', { group_id: @groupId }
