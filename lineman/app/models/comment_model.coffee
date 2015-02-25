angular.module('loomioApp').factory 'CommentModel', (BaseModel) ->
  class CommentModel extends BaseModel
    @singular: 'comment'
    @plural: 'comments'
    @indices: ['discussionId', 'authorId']

    initialize: (data) ->
      @updateFromJSON(data)

      if data.body?
        @body = data.body
      else
        @body = ''

      @newAttachmentIds = []

    serialize: ->
      data = baseSerialize()
      data[new_attachment_ids] = @newAttachmentIds
      data

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

    authorUsername: ->
      @author().username

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
