import { DirectUpload } from "activestorage";

export default class FileUploader {
  constructor({onProgress}) {
    this.onProgress = onProgress;
  }

  upload(file) {
    const url = "/direct_uploads";
    const upload = new DirectUpload(file, url, {
      directUploadWillStoreFileWithXHR: xhr => {
        return xhr.upload.addEventListener('progress', e => {
          if (e.lengthComputable) {
            return this.onProgress(e);
          }
        });
      }
    });

    return new Promise((resolve, reject) => upload.create(function(error, blob, delegate) {
      if (error) {
        return reject(error);
      } else {
        return resolve(blob);
      }
    }));
  }
}
