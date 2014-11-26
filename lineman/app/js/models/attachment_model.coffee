angular.module('loomioApp').factory 'AttachmentModel',  ->
  class AttachmentModel extends BaseModel
    plural: 'attachments'

    hydrate: (data) ->
      @filename = data.filename
      @location = data.location
      @filesize = data.filesize
      @authorId = data.user_id
      @commentId = data.comment_id

    author: ->
      @recordStore.users.get(@authorId)

    comment: ->
      @recordStore.comments.get(@commentId)
