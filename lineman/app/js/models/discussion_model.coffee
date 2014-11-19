angular.module('loomioApp').factory 'DiscussionModel', (RecordStoreService, BaseModel) ->
  class DiscussionModel extends BaseModel
    constructor: (data = {}) ->
      @callcount = 0
      @id = data.id
      @key = data.key
      @authorId = data.author_id
      @groupId = data.group_id
      @title = data.title
      @description = data.description
      @createdAt = data.created_at
      @lastActivityAt = data.last_activity_at
      @private = data.private

    plural: 'discussions'

    params: ->
      discussion:
        discussion_id: @discussionId
        title: @title
        description: @description
        private: @private

    author: ->
      RecordStoreService.get('users', @authorId)

    authorName: ->
      @author().name

    group: ->
      RecordStoreService.get 'groups', @groupId

    events: ->
      _.sortBy(@unsortedEvents(), 'sequenceId')

    unsortedEvents: ->
      RecordStoreService.get 'events', (event) =>
        event.discussionId == @id


    comments: ->
      RecordStoreService.get 'comments', (comment) =>
        comment.discussionId == @id

    proposals: ->
      RecordStoreService.get 'proposals', (proposal) =>
        proposal.discussionId == @id

    activeProposal: ->
      #@callcount = @callcount + 1
      #console.log('called activeProposal', @callcount)
      _.first(_.filter(@proposals(), (proposal) -> proposal.isActive()))
