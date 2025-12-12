<script setup lang="js">
import { ref, computed, watch, toRef } from 'vue';
import { convertToHtml } from '@/shared/services/format_converter';
import Records from '@/shared/services/records';
import FilesList from './files_list.vue';
import SuggestionList from './suggestion_list';
import { useCommonMentioning, useMdMentioning } from './composables/useMentioning';
import { useAttaching } from './composables/useAttaching';
import { useI18n } from 'vue-i18n';

const props = defineProps({
  model: Object,
  field: String,
  label: String,
  placeholder: String,
  maxLength: Number,
  autofocus: {
    type: Boolean,
    default: false
  }
});

const emit = defineEmits(['is-uploading']);

const { t } = useI18n();

// Refs
const preview = ref(false);
const fieldRef = ref(null);
const filesField = ref(null);

// Composables
const modelRef = toRef(props, 'model');
const fieldNameRef = toRef(props, 'field');

const {
  mentionsCache,
  mentions,
  query,
  navigatedUserIndex,
  suggestionListStyles,
  fetchingMentions,
  fetchMentionable,
  updateMentions
} = useCommonMentioning(modelRef);

// Get textarea element helper
const textarea = computed(() => {
  return fieldRef.value?.$el.querySelector('textarea');
});

const {
  onKeyUp,
  onKeyDown,
  selectRow
} = useMdMentioning(
  modelRef,
  fieldNameRef,
  textarea,
  query,
  mentions,
  navigatedUserIndex,
  suggestionListStyles,
  fetchMentionable,
  updateMentions
);

const {
  files,
  imageFiles,
  resetFiles,
  updateFiles,
  removeFile,
  attachFile,
  attachImageFile,
  fileSelected: fileSelectedBase
} = useAttaching(modelRef, emit);



// Methods
const reset = () => {
  preview.value = false;
  resetFiles();
};

const convertToHtmlHandler = () => {
  convertToHtml(props.model, props.field);
  Records.users.saveExperience('html-editor.uses-markdown', false);
};

const onPaste = (event) => {
  const items = Array.from(event.clipboardData.items);

  if (items.filter(item => item.getAsFile()).length === 0) { return; }

  event.preventDefault();
  handleUploads(items.map(item => {
    return new File([item.getAsFile()],
             event.clipboardData.getData('text/plain') || Date.now(),
             {lastModified: Date.now(), type: item.type});
  }));
};

const handleUploads = (uploadFiles) => {
  Array.from(uploadFiles).forEach(file => {
    if ((/image/i).test(file.type)) {
      insertImage(file);
    } else {
      attachFile({file});
    }
  });
};

const insertImage = (file) => {
  const name = file.name.replace(/[\W_]+/g, '') || 'file';

  const uploadingText = pct => `![uploading-${name}](${"*".repeat(parseInt(pct / 5))})`;

  const insertPlaceholder = text => {
    const beforeText = props.model[props.field].slice(0, textarea.value.selectionStart);
    const afterText = props.model[props.field].slice(textarea.value.selectionStart);
    props.model[props.field] = beforeText + "\n" + text + "\n" + afterText;
  };

  const updatePlaceholder = text => {
    props.model[props.field] = props.model[props.field].replace(new RegExp(`!\\[uploading-${name}\\]\\(\\**\\)`), text);
  };

  insertPlaceholder(uploadingText(0));

  return attachImageFile({
    file,
    onProgress: e => {
      updatePlaceholder(uploadingText(parseInt((e.loaded / e.total) * 100)));
    },

    onComplete: blob => {
      updatePlaceholder(`![${name}](${blob.preview_url})`);
    },

    onFailure: () => {
      updatePlaceholder(`![${name}](${t('formatting.upload_failed')})`);
    }
  });
};

const onDrop = (event) => {
  if (!event.dataTransfer || !event.dataTransfer.files || !event.dataTransfer.files.length) { return; }
  event.preventDefault();
  handleUploads(event.dataTransfer.files);
};

const onDragOver = (event) => { 
  return false; 
};

const fileSelected = () => {
  fileSelectedBase(filesField);
};

// Computed
const previewAction = computed(() => {
  if (preview.value) { 
    return 'common.action.edit'; 
  } else { 
    return 'common.action.preview'; 
  }
});

const previewIcon = computed(() => {
  if (preview.value) { 
    return 'mdi-pencil'; 
  } else { 
    return 'mdi-eye'; 
  }
});

defineExpose({
  reset,
  preview
});
</script>

<template lang="pug">
div(style="position: relative")
  v-textarea(
    v-if="!preview"
    filled
    ref="fieldRef"
    v-model="model[field]"
    :placeholder="placeholder"
    :label="label"
    @keyup="onKeyUp"
    @keydown="onKeyDown"
    @paste="onPaste"
    @drop="onDrop"
    @dragover.prevent="onDragOver")
  formatted-text(v-if="preview" :model="model" :field="field")
  v-sheet.pa-4.my-4.poll-common-outcome-panel(v-if="preview && model[field].trim().length == 0" color="primary lighten-5" elevation="2")
    p(v-t="'common.empty'")

  .d-flex.align-center.menubar(align-center :aria-label="$t('formatting.formatting_tools')")
    v-btn(icon size="x-small" variant="text" @click='filesField.click()' :title="$t('formatting.attach')")
      common-icon(name="mdi-paperclip")
    v-btn(variant="text" size="small" @click="convertToHtmlHandler" v-t="'formatting.wysiwyg'")
    v-spacer
    v-btn.mr-4(variant="text" size="small" @click="preview = !preview" v-t="previewAction")
    slot(name="actions")
  suggestion-list(:query="query" :loading="fetchingMentions" :mentions="mentions" :positionStyles="suggestionListStyles" :navigatedUserIndex="navigatedUserIndex" showUsername @select-row="selectRow")

  files-list(:files="files" v-on:removeFile="removeFile")

  form(style="display: block" @change="fileSelected")
    input.d-none(ref="filesField" type="file" name="files" multiple=true)
</template>
