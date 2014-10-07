angular.module('loomioApp').factory 'DiscussionModel', (RecordStoreService) ->
  class DiscussionModel
    constructor: (data = {}) ->
      @id = data.id
      @key = data.key
      @author_id = data.author_id
      @group_id = data.group_id
      @comment_ids = data.comment_ids
      @event_ids = data.event_ids
      @title = data.title
      @description = data.description

    plural: 'discussions'

    events: ->
      RecordStoreService.getAll('events', @event_ids)

    author: ->
      RecordStoreService.get('users', @author_id)

    comments: ->
      RecordStoreService.getAll('comments', @comment_ids)
