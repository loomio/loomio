angular.module('loomioApp').factory 'DiscussionModel', (RecordStoreService) ->
  class DiscussionModel
    constructor: (data = {}) ->
      @id = data.id
      @key = data.key
      @authorId = data.author_id
      @groupId = data.group_id
      @commentIds = data.comment_ids
      @eventIds = data.event_ids
      @title = data.title
      @description = data.description
      @createdAt = data.created_at
      @activeProposalId = data.active_proposal_id
      @private = data.private

    plural: 'discussions'

    group: ->
      RecordStoreService.get('groups', @groupId)

    events: ->
      RecordStoreService.getAll('events', @eventIds)

    author: ->
      RecordStoreService.get('users', @authorId)

    authorName: ->
      @author().name

    comments: ->
      RecordStoreService.getAll('comments', @commentIds)

    currentProposal: ->
      RecordStoreService.get('proposals', @activeProposalId)
