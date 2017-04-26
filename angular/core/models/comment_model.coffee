angular.module('loomioApp').factory 'CommentModel', (DraftableModel, AppConfig) ->
  class CommentModel extends DraftableModel
    @singular: 'comment'
    @plural: 'comments'
    @indices: ['discussionId', 'authorId']
    @serializableAttributes: AppConfig.permittedParams.comment
    @draftParent: 'discussion'
    @draftPayloadAttributes: ['body', 'attachment_ids']

    afterConstruction: ->
      @newAttachmentIds = _.clone(@attachmentIds) or []

    defaultValues: ->
      usesMarkdown: true
      discussionId: null
      body: ''
      likerIds:           []
      attachmentIds:      []
      mentionedUsernames: []

    relationships: ->
      @belongsTo 'author', from: 'users'
      @belongsTo 'discussion'
      @belongsTo 'parent', from: 'comments', by: 'parentId'
      @hasMany  'versions', sortBy: 'createdAt'

    serialize: ->
      data = @baseSerialize()
      data.comment.attachment_ids = @newAttachmentIds
      data

    group: ->
      @discussion().group()

    isMostRecent: ->
      _.last(@discussion().comments()) == @

    isReply: ->
      @parentId?

    hasContext: ->
      !!@body

    parent: ->
      @recordStore.comments.find(@parentId)

    likers: ->
      @recordStore.users.find(@likerIds)

    newAttachments: ->
      @recordStore.attachments.find(@newAttachmentIds)

    attachments: ->
      @recordStore.attachments.find(attachableId: @id, attachableType: 'Comment')

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

    cookedBody: ->
      cooked = @body
      _.each @mentionedUsernames, (username) ->
        cooked = cooked.replace(///@#{username}///g, "[[@#{username}]]")
      cooked

    edited: ->
      @versionsCount > 1

    attributeForVersion: (attr, version) ->
      return '' unless version
      if version.changes[attr]
        version.changes[attr][1]
      else
        @attributeForVersion(attr, @recordStore.versions.find(version.previousId))
