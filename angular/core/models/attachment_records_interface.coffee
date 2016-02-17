angular.module('loomioApp').factory 'AttachmentRecordsInterface', (BaseRecordsInterface, AttachmentModel) ->
  class AttachmentRecordsInterface extends BaseRecordsInterface
    model: AttachmentModel

    upload: (file, progress) ->
      @remote.upload '', file,
        data:
          'attachment[filename]': file.name.replace(/[^a-z0-9_\-\.]/gi, '_')
        fileFormDataName: 'attachment[file]'
      , progress
