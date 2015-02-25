angular.module('loomioApp').factory 'AttachmentModel', (BaseModel) ->
  class AttachmentModel extends BaseModel
    @singular: 'attachment'
    @plural: 'attachments'

    formattedFilesize: ->
      if @filesize < 100000
        "(#{(@filesize / 1000).toFixed(2)} KB)"
      else
        "(#{(@filesize / 1000000).toFixed(2)} MB)"

    author: ->
      @recordStore.users.get(@authorId)

    comment: ->
      @recordStore.comments.get(@commentId)
