angular.module('loomioApp').factory 'DiscussionModel', (BaseModel) ->
  class DiscussionModel extends BaseModel
    @singular: 'discussion'
    @plural: 'discussions'
    @uniqueIndices: ['id', 'key']
    @indices: ['groupId', 'authorId']

    # works out if new records are private
    privateDefaultValue: =>
      if @group()
        switch @group().discussionPrivacyOptions
          when 'private_only' then true
          when 'public_or_private' then undefined
          when 'public_only' then false
      else
        undefined

    defaultValues: =>
      private: null
      usesMarkdown: true
      lastSequenceId: 0
      firstSequenceId: 0
      lastItemAt: null
      title: ''
      description: ''

    relationships: ->
      @belongsTo 'group'
      @belongsTo 'author', from: 'users'

      @hasMany 'comments', dynamicView: false
      @hasMany 'events', sortBy: 'sequenceId'
      @hasMany 'proposals', sortBy: 'createdAt', sortDesc: true
      # not ready @hasOne 'reader', from: 'discussionReaders', with: 'id'

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
      @recordStore.discussionReaders.find(@id)

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
