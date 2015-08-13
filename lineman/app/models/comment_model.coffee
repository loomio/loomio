angular.module('loomioApp').factory 'CommentModel', (BaseModel) ->
  class CommentModel extends BaseModel
    @singular: 'comment'
    @plural: 'comments'
    @indices: ['id', 'discussionId', 'authorId']

    defaultValues: ->
      uses_markdown: true
      body: ''

    initialize: (data) ->
      @baseInitialize(data)
      @newAttachmentIds = []

    serialize: ->
      data = @baseSerialize()
      data['comment']['new_attachment_ids'] = @newAttachmentIds
      data

    group: ->
      @discussion().group()

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

    authorAvatar: ->
      @author().avatarOrInitials()

    addLiker: (user) ->
      @likerIds.push user.id

    removeLiker: (user) ->
      @removeLikerId(user.id)

    removeLikerId: (id) ->
      @likerIds = _.without(@likerIds, id)
