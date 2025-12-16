import { ref, watch, onMounted } from 'vue';
import FileUploader from '@/shared/services/file_uploader';
import { insertImage } from '../extension_image';
import { forEach } from 'lodash-es';
import { reactive } from 'vue';

export function useAttaching(model, emit) {
  const files = ref([]);
  const imageFiles = ref([]);

  onMounted(() => {
    files.value = model.value.attachments.filter(a => a.signed_id).map(a => ({
      blob: a,
      file: { name: a.filename }
    }));
  });

  watch(files, () => {
    updateFiles();
  });

  watch(imageFiles, () => {
    updateFiles();
  });

  const resetFiles = () => {
    files.value = [];
    imageFiles.value = [];
  };

  const updateFiles = () => {
    model.value.files = files.value.filter(w => w.blob).map(wrapper => wrapper.blob.signed_id);
    model.value.imageFiles = imageFiles.value.filter(w => w.blob).map(wrapper => wrapper.blob.signed_id);
    emitUploading();
  };

  const emitUploading = () => {
    if (emit) {
      emit('is-uploading', !(((model.value.files || []).length === files.value.length) && 
                             ((model.value.imageFiles || []).length === imageFiles.value.length)));
    }
  };

  const removeFile = (name) => {
    files.value = files.value.filter(wrapper => wrapper.file.name !== name);
  };

  const attachFile = ({ file }) => {
    const wrapper = reactive({ 
      file, 
      key: file.name + file.size, 
      percentComplete: 0, 
      blob: null 
    });
    files.value.push(wrapper);
    emitUploading();
    
    const uploader = new FileUploader({
      onProgress(e) {
        wrapper.percentComplete = parseInt((e.loaded / e.total) * 100);
      }
    });

    uploader.upload(file).then(blob => {
      wrapper.blob = blob;
      updateFiles();
    }, (e) => console.log("attachment failed to upload", e));
  };

  const attachImageFile = ({ file, onProgress, onComplete, onFailure }) => {
    const wrapper = { file, blob: null };
    imageFiles.value.push(wrapper);
    emitUploading();
    const uploader = new FileUploader({ onProgress });
    uploader.upload(file).then(blob => {
      wrapper.blob = blob;
      onComplete(blob);
      updateFiles();
    }, onFailure);
  };

  const fileSelected = (filesFieldRef) => {
    forEach(filesFieldRef.value.files, file => attachFile({ file }));
  };

  // collab editor only
  const mediaRecorded = (blob, editor) => {
    insertImage(blob, editor.value.view, null, attachImageFile);
  };

  const imageSelected = (imagesFieldRef, editor) => {
    Array.from(imagesFieldRef.value.files || []).forEach(file => {
      if ((/image|video/i).test(file.type)) {
        insertImage(file, editor.value.view, null, attachImageFile);
      } else {
        attachFile({ file });
      }
    });
  };

  return {
    files,
    imageFiles,
    resetFiles,
    updateFiles,
    emitUploading,
    removeFile,
    attachFile,
    attachImageFile,
    fileSelected,
    mediaRecorded,
    imageSelected
  };
}
