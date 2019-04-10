import { DirectUpload } from "activestorage"

module.exports = class FileUploader
  constructor: ({onProgress}) ->
    @onProgress = onProgress

  upload: (file) ->
    url = "/direct_uploads"
    upload = new DirectUpload(file, url, {
      directUploadWillStoreFileWithXHR: (xhr) =>
        xhr.upload.addEventListener 'progress', (e) =>
          if (e.lengthComputable)
            @onProgress(e)
    })

    new Promise (resolve, reject) ->
      upload.create (error, blob, delegate) ->
        if error
          reject(error)
        else
          resolve(blob)
