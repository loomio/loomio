angular.module('loomioApp').factory 'DiscussionModel', (BaseModel) ->
  class DiscussionModel extends BaseModel
    @singular: 'discussion'
    @plural: 'discussions'
    @indices: ['groupId', 'authorId']

    setupViews: ->
      @setupView 'comments'
      @setupView 'proposals', 'createdAt', true
      @setupView 'events', 'sequenceId'

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

    activeProposal: ->
      proposal = _.last(@proposals())
      if proposal and proposal.isActive()
        proposal
      else
        null

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

    markAsRead: (sequenceId) ->
      if @reader().lastReadSequenceId < sequenceId
        @restfulClient.patchMember(@keyOrId(), 'mark_as_read', {sequence_id: sequenceId})
