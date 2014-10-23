angular.module('loomioApp').service 'AttachmentService',
  class AttachmentService
    constructor: (@$http, @$upload, @FileUploadService) ->

    upload: (attachment, progress, success, failure) ->
      s3_params = @FileUploadService.getParams(attachment)
      @$upload.upload(s3_params)
              .progress(progress)
              .error(failure)
              .abort(failure)
              .success (response, status, xhr, data) ->
                console.log('upload success!')
                attachment = AttachmentService.build(data.file)
                AttachmentService.create(attachment, success, failure)

    build: (file) ->
      { file: 'sample' }

    create: (file, success, failure) ->
      @$http.post("/api/v1/attachments", attachment).then (response) ->
        success(response)
      , (response) ->
        failure(response.data.errors)

    remove: (attachment) ->
      @$http.delete("/api/v1/attachments/#{attachment.id}").then (response) ->
