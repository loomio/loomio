angular.module('loomioApp').factory 'AttachmentService', ($http, $upload, FileUploadService, RestfulService, Records) ->
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
                  attachment = Records.attachements.new(response['attachments'][0])
                  success(attachment)
                , failure(response)

    abort: ->
      $upload.abort()
