angular.module('loomioApp').factory 'DiscussionModel', (BaseModel) ->
  class DiscussionModel extends BaseModel
    @singular: 'discussion'
    @plural: 'discussions'
    @foreignKey: 'discussionId'
    @indexes: ['groupId']

    initialize: (data) ->
      @id = data.id
      @key = data.key
      @authorId = data.author_id
      @groupId = data.group_id
      @title = data.title
      @description = data.description
      @createdAt = data.created_at
      @lastActivityAt = data.last_activity_at
      @private = data.private

    setupViews: ->
      @commentsView = @recordStore.comments.addDynamicView(@viewName())
      @commentsView.applyFind(discussionId: @id)
      @commentsView.applySimpleSort('createdAt')

      @eventsView = @recordStore.events.addDynamicView(@viewName())
      @eventsView.applyFind(discussionId: @id)
      @eventsView.applySimpleSort('sequenceId')

      @proposalsView = @recordStore.proposals.addDynamicView(@viewName())
      @proposalsView.applyFind(discussionId: @id)
      @proposalsView.applySimpleSort('id')

    serialize: ->
      discussion:
        group_id: @groupId
        discussion_id: @discussionId
        title: @title
        description: @description
        private: @private

    author: ->
      @recordStore.users.get(@authorId)

    authorName: ->
      @author().name

    group: ->
      @recordStore.groups.get(@groupId)

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

    activeProposalClosedAt: ->
      proposal = @activeProposal()
      proposal.closedAt if proposal?
