angular.module('loomioApp').service 'AttachmentService',
  class AttachmentService
    constructor: (@$http, @$upload, @FileUploadService) ->

    add: (attachment, progress, success, failure) ->
      s3_params = @FileUploadService.getParams(attachment)
      @$upload.upload(s3_params)
              .progress(progress)
              .success(success)
              .error(failure)

    remove: (attachment) ->
      @$http.delete("/api/v1/attachments/#{attachment.id}").then (response) ->
