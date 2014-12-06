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
      #@dynamicView('comments')
      ##@hasMany('comments', discussionId: @id)
      #@recordStore.comments.addD
      @commentsView = @recordStore.comments.collection.addDynamicView(@viewName())
      @commentsView.applyFind(discussionId: @id)
      @commentsView.applySimpleSort('createdAt')

      @eventsView = @recordStore.events.collection.addDynamicView(@viewName())
      @eventsView.applyFind(discussionId: @id)
      @eventsView.applySimpleSort('sequenceId')

      @proposalsView = @recordStore.proposals.collection.addDynamicView(@viewName())
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

    activeProposalClosedAt: ->
      proposal = @activeProposal()
      proposal.closedAt if proposal?
