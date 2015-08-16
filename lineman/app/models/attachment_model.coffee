angular.module('loomioApp').factory 'AttachmentModel', (BaseModel, AppConfig) ->
  class AttachmentModel extends BaseModel
    @singular: 'attachment'
    @plural: 'attachments'
    @indices: ['id', 'commentId']
    @serializableAttributes: AppConfig.permittedParams.attachment

    relationships: ->
      @belongsTo 'author', from: 'users', by: 'authorId'
      @belongsTo 'comment', from: 'comments', by: 'commentId'

    formattedFilesize: ->
      if isNaN(@filesize) then return "(invalid file size)"

      if @filesize < 1000
        denom = "bytes"
        size = @filesize
      else if @filesize < Math.pow(1000, 2)
        denom = "kB"
        size = @filesize / 1000
      else if @filesize < Math.pow(1000, 3)
        denom = "MB"
        size = @filesize / Math.pow(1000, 2)
      else
        denom = "GB"
        size = @filesize / Math.pow(1000, 3)

      "(#{size.toFixed(1)} #{denom})"

