angular.module('loomioApp').factory 'DiscussionModel', (BaseModel) ->
  class DiscussionModel extends BaseModel
    @singular: 'discussion'
    @plural: 'discussions'
    @indices: ['id', 'key', 'groupId', 'authorId']

    setupViews: ->
      @setupView 'comments'
      @setupView 'events', 'sequenceId'
      @setupView 'proposals', 'createdAt', true

    translationOptions: ->
      title:     @title
      groupName: @groupName()

    author: ->
      @recordStore.users.find(@authorId)

    authorName: ->
      @author().name

    group: ->
      @recordStore.groups.find(@groupId)

    groupName: ->
      @group().name

    events: ->
      @eventsView.data()

    comments: ->
      @commentsView.data()

    proposals: ->
      @proposalsView.data()

    activeProposals: ->
      _.filter @proposalsView.data(), (proposal) ->
        proposal.isActive()

    closedProposals: ->
      _.reject @proposalsView.data(), (proposal) ->
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
      @recordStore.discussionReaders.initialize(id: @id)

    readerNotLoaded: ->
      !@reader().discussionId?

    isUnread: ->
      @unreadActivityCount() > 0

    isMuted: ->
      @reader().volume == 'mute'

    isParticipating: ->
      @reader().participating

    unreadItemsCount: ->
      @itemsCount - @reader().readItemsCount

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
