angular.module('loomioApp').factory 'CommentModel', (RecordStoreService) ->
  class CommentModel
    constructor: (data = {}) ->
      @id = data.id
      @authorId = data.author_id
      @parentId = data.parent_id
      @body = data.body
      @likerIds = data.liker_ids
      @createdAt = data.created_at
      @updatedAt = data.updated_at

    plural: 'comments'

    likers: ->
      RecordStoreService.getAll('users', @likerIds)

    author: ->
      RecordStoreService.get('users', @authorId)

    parent: ->
      RecordStoreService.get('comments', @parentId)

    discussion: ->
      RecordStoreService.get('discussions', @discussionId)

    authorName: ->
      @author().name

    authorAvatar: ->
      @author().avatarOrInitials()
