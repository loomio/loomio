angular.module('loomioApp').factory 'DiscussionModel', (BaseModel) ->
  class DiscussionModel extends BaseModel
    plural: 'discussions'
    foreignKey: 'discussionId'

    constructor: (data) ->
      @key = data.key
      @authorId = data.author_id
      @groupId = data.group_id
      @title = data.title
      @description = data.description
      @createdAt = data.created_at
      @lastActivityAt = data.last_activity_at
      @private = data.private

      #@commentsView = RecordStore.comments.belongingTo(@)

      #@eventsView = RecordStore.events.belongingTo(@)
      #@eventsView.applySimpleSort('sequenceId')

      #@proposalsView = RecordStore.proposals.belongingTo(@)
      #@proposalsView.applySimpleSort('createdAt')

    params: ->
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
      proposal = _.last(@proposals)
      if proposal and proposal.isActive()
        proposal
      else
        null
