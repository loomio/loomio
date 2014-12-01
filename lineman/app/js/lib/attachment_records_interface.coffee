angular.module('loomioApp').factory 'AttachmentRecordsInterface', ($upload, BaseRecordsInterface, FileUploadService, AttachmentModel) ->
  class AttachmentRecordsInterface extends BaseRecordsInterface
    model: AttachmentModel

    upload: (file, progress, success, failure) ->
      params = FileUploadService.getParams(file)

      @newAttachment = @recordStore.attachments.initialize
        filename: params.file.name
        filesize: params.file.size
        location: params.url + params.data.key

      $upload.upload(params)
             .progress(progress)
             .error(failure)
             .abort(failure)
             .success (response, status, xhr, data) =>
                @save @newAttachment, (response) ->
                  attachment = @recordStore.attachments.new(response['attachments'][0])
                  success(attachment)
                , failure(response)

    abortUpload: ->
      $upload.abort()
