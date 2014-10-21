angular.module('loomioApp').factory 'AttachmentModel', (RecordStoreService) ->
  class AttachmentModel
    constructor: (data = {}) ->
      @id = data.id
      @filename = data.filename
      @location = data.location
      @filesize = data.filesize
      @authorId = data.author_id
      @commentId = data.comment_id

    plural: 'attachments'

    author: ->
      RecordStoreService.get('user', @authorId)

    comment: ->
      RecordStoreService.get('comment', @commentId)
