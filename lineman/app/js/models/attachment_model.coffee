angular.module('loomioApp').factory 'AttachmentModel', (RecordStoreService, BaseModel) ->
  class AttachmentModel extends BaseModel
    constructor: (data = {}) ->
      @id = data.id
      @filename = data.filename
      @location = data.location
      @filesize = data.filesize
      @authorId = data.user_id
      @commentId = data.comment_id

    plural: 'attachments'

    params: ->
      filename: @filename
      location: @location
      filesize: @filesize
      user_id: @userId
      comment_id: @commentId

    author: ->
      RecordStoreService.get('user', @authorId)

    comment: ->
      RecordStoreService.get('comment', @commentId)
