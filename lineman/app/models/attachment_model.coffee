angular.module('loomioApp').factory 'AttachmentModel', (BaseModel) ->
  class AttachmentModel extends BaseModel
    @singular: 'attachment'
    @plural: 'attachments'

    initialize: (data) ->
      @id       = data.id
      @filename = data.filename
      @location = data.location
      @filesize = data.filesize
      @authorId = data.user_id
      @commentId = data.comment_id

    serialize: ->
      filename: @filename
      location: @location
      filesize: @filesize
      user_id: @userId
      comment_id: @commentId

    author: ->
      @recordStore.users.get(@authorId)

    comment: ->
      @recordStore.comments.get(@commentId)
