/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
import { forEach } from 'lodash';
import FileUploader from '@/shared/services/file_uploader';
import {insertImage} from './extension_image';
export default
  ({
    data() {
      return {
        files: [],
        imageFiles: []
      };
    },

    created() {
      return this.files = this.model.attachments.filter(a => a.signed_id).map(a => ({
        blob: a,
        file: {name: a.filename}
      }));
    },

    watch: {
      files() { return this.updateFiles(); },
      imageFiles() { return this.updateFiles(); }
    },

    methods: {
      resetFiles() {
        this.files = [];
        return this.imageFiles = [];
      },

      updateFiles() {
        this.model.files = this.files.filter(w => w.blob).map(wrapper => wrapper.blob.signed_id);
        this.model.imageFiles = this.imageFiles.filter(w => w.blob).map(wrapper => wrapper.blob.signed_id);
        return this.emitUploading();
      },

      emitUploading() {
        return this.$emit('is-uploading', !(((this.model.files || []).length === this.files.length) && ((this.model.imageFiles || []).length === this.imageFiles.length)));
      },

      removeFile(name) {
        return this.files = this.files.filter(wrapper => wrapper.file.name !== name);
      },

      attachFile({file}) {
        const wrapper = {file, key: file.name+file.size, percentComplete: 0, blob: null};
        this.files.push(wrapper);
        this.emitUploading();
        const uploader = new FileUploader({onProgress(e) {
          return wrapper.percentComplete = parseInt((e.loaded / e.total) * 100);
        }
        });

        return uploader.upload(file).then(blob => {
          wrapper.blob = blob;
          return this.updateFiles();
        }
        ,
        e => console.log("attachment failed to upload"));
      },

      attachImageFile({file, onProgress, onComplete, onFailure}) {
        const wrapper = {file, blob: null};
        this.imageFiles.push(wrapper);
        this.emitUploading();
        const uploader = new FileUploader({onProgress});
        return uploader.upload(file).then(blob => {
          wrapper.blob = blob;
          onComplete(blob);
          return this.updateFiles();
        }
        , onFailure);
      },

      fileSelected() {
        return forEach(this.$refs.filesField.files, file => this.attachFile({file}));
      },

      // collab editor only
      mediaRecorded(blob) {
        return insertImage(blob, this.editor.view, null, this.attachImageFile);
      },

      imageSelected() {
        // console.log 'state', @editor.state.tr.selection.from
        return Array.from(this.$refs.imagesField.files || []).forEach(file => {
          if ((/image|video/i).test(file.type)) {
            return insertImage(file, this.editor.view, null, this.attachImageFile);
          } else {
            return this.attachFile({file});
          }
        });
      }
    }
  });
