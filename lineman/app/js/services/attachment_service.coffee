angular.module('loomioApp').factory 'AttachmentService', ($http, $upload, FileUploadService, RestfulService, AttachmentModel) ->
  new class AttachmentService extends RestfulService
    resource_plural: 'attachments'

    upload: (file, progress, success, failure) ->
      params = FileUploadService.getParams(file)
      @newAttachment = new AttachmentModel(
        filename: params.file.name
        filesize: params.file.size
        location: params.url + params.data.key
      )
  
      $upload.upload(params)
             .progress(progress)
             .error(failure)
             .abort(failure)
             .success (response, status, xhr, data) =>
                @save @newAttachment, (response) ->
                  attachment = new AttachmentModel(response['attachments'][0])
                  success(attachment)
                , failure(response)

    remove: (attachment) ->
      $http.delete("/api/v1/attachments/#{attachment.id}").then (response) ->
