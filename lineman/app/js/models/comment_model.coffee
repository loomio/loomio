angular.module('loomioApp').factory 'CommentModel', (BaseModel) ->
  class CommentModel extends BaseModel
    plural: 'comments'
    foreignKey: 'commentId'

    hydrate: (data) ->
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

    group: ->
      @discussion.group()

    canBeEditedByAuthor: ->
      @group.membersCanEditComments or @isMostRecent()

    isMostRecent: ->
      _.last(@discussion().comments()).primaryId == @primaryId

    isReply: ->
      @parentId?

    likers: ->
      @recordStore.users.get(@likerIds)

    attachments: ->
      @attachmentsView.data()

    author: ->
      @recordStore.users.get(@authorId)

    parent: ->
      @recordStore.comments.get(@parentId)

    discussion: ->
      @recordStore.discussions.get(@discussionId)

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
