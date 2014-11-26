angular.module('loomioApp').factory 'AttachmentService', ($http, $upload, FileUploadService) ->
  new class AttachmentService
    upload: (attachment, progress, success, failure) ->
      params = FileUploadService.getParams(attachment)
      @success = success
      @failure = failure
      @newAttachment =
        attachment:
          filename: params.file.name
          filesize: params.file.size
          location: params.url + params.data.key

      $upload.upload(params)
             .progress(progress)
             .error(failure)
             .abort(failure)
             .success (response, status, xhr, data) =>
               $http.post("/api/v1/attachments", @newAttachment).then (response) =>
                 @success(response.data)
               , (response) ->
                 @failure(response.data.errors)

    remove: (attachment) ->
      $http.delete("/api/v1/attachments/#{attachment.id}").then (response) ->
