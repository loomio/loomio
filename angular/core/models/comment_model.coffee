angular.module('loomioApp').factory 'CommentModel', (BaseModel, HasDrafts, HasDocuments, AppConfig) ->
  class CommentModel extends BaseModel
    @singular: 'comment'
    @plural: 'comments'
    @indices: ['discussionId', 'authorId']
    @serializableAttributes: AppConfig.permittedParams.comment
    @draftParent: 'discussion'
    @draftPayloadAttributes: ['body', 'document_ids']

    afterConstruction: ->
      HasDrafts.apply @
      HasDocuments.apply @

    defaultValues: ->
      usesMarkdown: true
      discussionId: null
      body: ''
      mentionedUsernames: []

    relationships: ->
      @belongsTo 'author', from: 'users'
      @belongsTo 'discussion'
      @belongsTo 'parent', from: 'comments', by: 'parentId'
      @hasMany  'versions', sortBy: 'createdAt'

    reactions: ->
      @recordStore.reactions.find
        reactableId: @id
        reactableType: _.capitalize(@constructor.singular)

    group: ->
      @discussion().group()

    isMostRecent: ->
      _.last(@discussion().comments()) == @

    isReply: ->
      @parentId?

    hasDescription: ->
      !!@body

    parent: ->
      @recordStore.comments.find(@parentId)

    reactors: ->
      @recordStore.users.find(_.pluck(@reactions(), 'userId'))

    authorName: ->
      @author().name

    authorUsername: ->
      @author().username

    authorAvatar: ->
      @author().avatarOrInitials()

    cookedBody: ->
      cooked = @body
      _.each @mentionedUsernames, (username) ->
        cooked = cooked.replace(///@#{username}///g, "[[@#{username}]]")
      cooked

    beforeDestroy: ->
      _.invoke @recordStore.events.find(kind: 'new_comment', eventableId: @id), 'remove'

    edited: ->
      @versionsCount > 1

    attributeForVersion: (attr, version) ->
      return '' unless version
      if version.changes[attr]
        version.changes[attr][1]
      else
        @attributeForVersion(attr, @recordStore.versions.find(version.previousId))
