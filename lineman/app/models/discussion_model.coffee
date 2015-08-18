angular.module('loomioApp').factory 'DiscussionModel', (BaseModel) ->
  class DiscussionModel extends BaseModel
    @singular: 'discussion'
    @plural: 'discussions'
    @indices: ['id', 'key', 'groupId', 'authorId']

    defaultValues: ->
      usesMarkdown: true
      lastSequenceId: 0
      firstSequenceId: 0
      lastItemAt: null

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
      @group().name if @group()

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

    isUnread: ->
      if @lastReadAt?
        @unreadActivityCount() > 0
      else
        true

    isMuted: ->
      @volume == 'mute'

    isParticipating: ->
      @participating

    isStarred: ->
      @starred

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

    changeVolume: (volume) ->
      @volume = volume
      @save()

    toggleStar: ->
      @starred = !@starred
      @save()

    markAsRead: (sequenceId) ->
      if isNaN(sequenceId)
        sequenceId = @lastSequenceId

      if _.isNull(@lastReadAt) or @lastReadSequenceId < sequenceId
        @restfulClient.patchMember(@keyOrId(), 'mark_as_read', {sequence_id: sequenceId})
        @lastReadSequenceId = sequenceId
