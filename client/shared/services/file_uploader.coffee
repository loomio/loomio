import { DirectUpload } from "activestorage"

module.exports = class FileUploader
  constructor: (fileXHRCallbacks, blobXHRCallbacks) ->
    @fileXHRCallbacks = fileXHRCallbacks
    @blobXHRCallbacks = blobXHRCallbacks

  upload: (file) ->
    console.log @fileXHRCallbacks
    url = "/direct_uploads"
    upload = new DirectUpload(file, url, {
      directUploadWillCreateBlobWithXHR: (xhr) =>
        _.forEach @blobXHRCallbacks, (value, key) ->
          xhr.upload.addEventListener(key, value)

      directUploadWillStoreFileWithXHR: (xhr) =>
        _.forEach @fileXHRCallbacks, (value, key) ->
          xhr.upload.addEventListener(key, value)
    })

    new Promise (resolve, reject) ->
      upload.create (error, blob, delegate) ->
        if error
          reject(error)
        else
          resolve(blob)
