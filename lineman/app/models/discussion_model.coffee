angular.module('loomioApp').factory 'DiscussionModel', (BaseModel) ->
  class DiscussionModel extends BaseModel
    @singular: 'discussion'
    @plural: 'discussions'
    @indices: ['groupId', 'authorId']

    setupViews: ->
      @setupView 'comments'
      @setupView 'proposals', 'createdAt', true
      @setupView 'events', 'sequenceId'

      @activeProposalView = @recordStore.proposals.collection.addDynamicView("#{@id}-activeProposal")
      @activeProposalView.applyFind('discussionId': @id)
      @activeProposalView.applyFind('id': {'$gt': 0})
      @activeProposalView.applyFind('closedAt': {'$eq': null})
      @activeProposalView.applySimpleSort('createdAt', true)

      @closedProposalsView = @recordStore.proposals.collection.addDynamicView("#{@id}-closedProposals")
      @closedProposalsView.applyFind('discussionId': @id)
      @closedProposalsView.applyFind('closedAt': {'$gt': 0})
      @closedProposalsView.applySimpleSort('createdAt', true)

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

    latestEvent: ->
      @events()[0] if @events()?

    comments: ->
      @commentsView.data()

    proposals: ->
      @proposalsView.data()

    closedProposals: ->
      @closedProposalsView.data()

    anyClosedProposals: ->
      _.some(@closedProposals())

    activeProposal: ->
      _.first(@activeProposalView.data())

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

    isUnread: ->
      @unreadActivityCount() > 0

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
