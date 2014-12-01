angular.module('loomioApp').factory 'CommentModel', (BaseModel) ->
  class CommentModel extends BaseModel
    @singular: 'comment'
    @plural: 'comments'
    @indexes: ['discussionId', 'authorId']

    initialize: (data) ->
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

    serialize: ->
      comment:
        parent_id: @parentId
        discussion_id: @discussionId
        body: @body
        new_attachment_ids: @newAttachmentIds

    group: ->
      @discussion().group()

    canBeEditedByAuthor: ->
      @group().membersCanEditComments or @isMostRecent()

    isMostRecent: ->
      _.last(@discussion().comments()) == @

    isReply: ->
      @parentId?

    likers: ->
      @recordStore.users.find(@likerIds)

    newAttachments: ->
      @recordStore.attachments.find(@newAttachmentIds)

    attachments: ->
      @recordStore.attachments.find(commentId: @id)

    author: ->
      @recordStore.users.find(@authorId)

    parent: ->
      @recordStore.comments.find(@parentId)

    discussion: ->
      @recordStore.discussions.find(@discussionId)

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
      _.each @events, (event) ->
        @recordStore.events.remove(event)

      @recordStore.comments.remove(@)
