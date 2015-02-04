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
      @isAnImage = data.is_an_image

    serialize: ->
      filename: @filename
      location: @location
      filesize: @filesize
      user_id: @userId
      comment_id: @commentId

    formattedFilesize: ->
      if @filesize < 100000
        "(#{(@filesize / 1000).toFixed(2)} KB)"
      else
        "(#{(@filesize / 1000000).toFixed(2)} MB)"

    author: ->
      @recordStore.users.get(@authorId)

    comment: ->
      @recordStore.comments.get(@commentId)
