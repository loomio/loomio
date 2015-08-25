angular.module('loomioApp').factory 'DiscussionModel', (BaseModel, AppConfig) ->
  class DiscussionModel extends BaseModel
    @singular: 'discussion'
    @plural: 'discussions'
    @uniqueIndices: ['id', 'key']
    @indices: ['groupId', 'authorId']
    @serializableAttributes: AppConfig.permittedParams.discussion

    afterConstruction: ->
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

    reader: ->
      @recordStore.discussionReaders.import(id: @id)

    readerNotLoaded: ->
      !@reader().discussionId?

    isUnread: ->
      if @reader().lastReadAt?
        @unreadActivityCount() > 0
      else
        true

    isMuted: ->
      @reader().volume == 'mute'

    isParticipating: ->
      @reader().participating

    isStarred: ->
      @reader().starred

    isImportant: ->
      @isStarred() or @hasActiveProposal()

    unreadItemsCount: ->
      (@itemsCount - @reader().readItemsCount)

    unreadActivityCount: ->
      @salientItemsCount - @reader().readSalientItemsCount

    unreadCommentsCount: ->
      @commentsCount - @reader().readCommentsCount

    lastInboxActivity: ->
      @activeProposalClosingAt() or @lastActivityAt

    unreadPosition: ->
      @reader().lastReadSequenceId + 1

    markAsRead: (sequenceId) ->
      @reader().markAsRead(sequenceId)

    minLoadedSequenceId: ->
      item = _.min @events(), (event) -> event.sequenceId or Number.MAX_VALUE
      item.sequenceId

    maxLoadedSequenceId: ->
      item = _.max @events(), (event) -> event.sequenceId or 0
      item.sequenceId
