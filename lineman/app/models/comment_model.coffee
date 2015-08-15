angular.module('loomioApp').factory 'CommentModel', (BaseModel) ->
  class CommentModel extends BaseModel
    @singular: 'comment'
    @plural: 'comments'
    @indices: ['id', 'discussionId', 'authorId']

    defaultValues: ->
      usesMarkdown: true
      newAttachmentIds: []
      body: ''

    relationships: ->
      @belongsTo 'author', from: 'users'
      @belongsTo 'discussion'
      @belongsTo 'parent', from: 'comments', by: 'parentId'

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
