angular.module('loomioApp').factory 'CommentModel', (RecordStoreService, BaseModel) ->
  class CommentModel extends BaseModel
    constructor: (data = {}) ->
      @id = data.id
      @discussionId = data.discussion_id
      @authorId = data.author_id
      @parentId = data.parent_id

      if data.body?
        @body = data.body
      else
        @body = ''

      @likerIds = data.liker_ids
      @newAttachmentIds = []
      @createdAt = data.created_at
      @updatedAt = data.updated_at

    params: ->
      comment:
        parent_id: @parentId
        discussion_id: @discussionId
        body: @body
        new_attachment_ids: @newAttachmentIds

    plural: 'comments'

    group: ->
      @discussion().group()

    canBeEditedByAuthor: ->
      @group.membersCanEditComments or @isMostRecent()

    isMostRecent: ->
      newerComments = RecordStoreService.get 'comments', (comment) =>
        (comment.discussionId == @discussionId) && (@comment.createdAt > @createdAt)
      newerComments.length == 0

    isReply: ->
      @parentId?

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

    parentAuthorName: ->
      return null unless @parentId
      @parent().authorName()

    authorAvatar: ->
      @author().avatarOrInitials()

    addLiker: (user) ->
      @likerIds.push user.id

    removeLiker: (user) ->
      @removeLikerId(user.id)

    removeLikerId: (id) ->
      @likerIds = _.without(@likerIds, id)

    destroy: ->
      events = RecordStoreService.get 'events', (event) =>
        (event.kind == 'new_comment') && (event.commentId == @id)

      _.each events, (event) ->
        RecordStoreService.remove(event)

      RecordStoreService.remove(@)
