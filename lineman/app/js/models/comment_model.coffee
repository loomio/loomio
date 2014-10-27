angular.module('loomioApp').factory 'CommentModel', (RecordStoreService) ->
  class CommentModel
    constructor: (data = {}) ->
      @id = data.id
      @discussionId = data.discussion_id
      @authorId = data.author_id
      @parentId = data.parent_id
      @body = data.body
      @likerIds = data.liker_ids
      @newAttachmentIds = []
      @createdAt = data.created_at
      @updatedAt = data.updated_at

    params: ->
      author_id: @authorId
      parent_id: @parentId
      discussion_id: @discussionId
      body: @body
      new_attachment_ids: @newAttachmentIds

    plural: 'comments'

    likers: ->
      RecordStoreService.get('users', @likerIds)

    attachments: ->
      RecordStoreService.get 'attachments', (attachment) =>
        attachment.commentId == @id

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

    addLiker: (user) ->
      @likerIds.push user.id

    removeLiker: (user) ->
      @likerIds = _.without(@likerIds, user.id)
