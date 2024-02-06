<script lang="js">
import { convertToHtml } from '@/shared/services/format_converter';
import { CommonMentioning, MdMentioning } from './mentioning';
import Records from '@/shared/services/records';
import FilesList from './files_list.vue';
import SuggestionList from './suggestion_list';
import Attaching from './attaching';

export default
{
  mixins: [CommonMentioning, MdMentioning, Attaching],
  props: {
    model: Object,
    field: String,
    label: String,
    placeholder: String,
    shouldReset: Boolean,
    maxLength: Number,
    autofocus: {
      type: Boolean,
      default: false
    }
  },

  components: {
    FilesList,
    SuggestionList
  },

  data() {
    return {preview: false};
  },

  watch: {
    shouldReset: 'reset'
  },

  methods: {
    reset() {
      this.preview = false;
      this.resetFiles();
    },

    convertToHtml() {
      convertToHtml(this.model, this.field);
      Records.users.saveExperience('html-editor.uses-markdown', false);
    },

    onPaste(event) {
      const items = Array.from(event.clipboardData.items);

      if (items.filter(item => item.getAsFile()).length === 0) { return; }

      event.preventDefault();
      this.handleUploads(items.map(item => {
        return new File([item.getAsFile()],
                 event.clipboardData.getData('text/plain') || Date.now(),
                 {lastModified: Date.now(), type: item.type});
      })
      );
    },

    handleUploads(files) {
      Array.from(files).forEach(file => {
        if ((/image/i).test(file.type)) {
          this.insertImage(file);
        } else {
          this.attachFile({file});
        }
      });
    },

    insertImage(file) {
      const name = file.name.replace(/[\W_]+/g, '') | 'file';

      const uploadingText = pct => `![uploading-${name}](${"*".repeat(parseInt(pct / 5))})`;

      const insertPlaceholder = text => {
        const beforeText = this.model[this.field].slice(0, this.textarea().selectionStart);
        const afterText = this.model[this.field].slice(this.textarea().selectionStart);
        this.model[this.field] = beforeText + "\n" + text + "\n" + afterText;
      };

      const updatePlaceholder = text => {
        this.model[this.field] = this.model[this.field].replace(new RegExp(`!\\[uploading-${name}\\]\\(\\**\\)`), text);
      };

      insertPlaceholder(uploadingText(0));

      return this.attachImageFile({
        file,
        onProgress: e => {
          updatePlaceholder(uploadingText(parseInt((e.loaded / e.total) * 100)));
        },

        onComplete: blob => {
          updatePlaceholder(`![${name}](${blob.preview_url})`);
        },

        onFailure: () => {
          updatePlaceholder(`![${name}](${this.$t('formatting.upload_failed')}`);
        }
      });
    },

    onDrop(event) {
      if (!event.dataTransfer || !event.dataTransfer.files || !event.dataTransfer.files.length) { return; }
      event.preventDefault();
      this.handleUploads(event.dataTransfer.files);
    },

    onDragOver(event) { return false; }
  },

  computed: {
    previewAction() {
      if (this.preview) { return 'common.action.edit'; } else { return 'common.action.preview'; }
    },
    previewIcon() {
      if (this.preview) { return 'mdi-pencil'; } else { return 'mdi-eye'; }
    }
  }
};

</script>

<template lang="pug">
div(style="position: relative")
  v-textarea(
    v-if="!preview"
    filled
    ref="field"
    v-model="model[field]"
    :placeholder="placeholder"
    :label="label"
    @keyup="onKeyUp"
    @keydown="onKeyDown"
    @paste="onPaste"
    @drop="onDrop"
    @dragover.prevent="onDragOver")
  formatted-text(v-if="preview" :model="model" :column="field")
  v-sheet.pa-4.my-4.poll-common-outcome-panel(v-if="preview && model[field].trim().length == 0" color="primary lighten-5" elevation="2")
    p(v-t="'common.empty'")

  v-layout.menubar(align-center :aria-label="$t('formatting.formatting_tools')")
    v-btn(icon @click='$refs.filesField.click()' :title="$t('formatting.attach')")
      common-icon(name="mdi-paperclip")
    v-btn(text x-small @click="convertToHtml(model, field)" v-t="'formatting.wysiwyg'")
    v-spacer
    v-btn.mr-4(text x-small @click="preview = !preview" v-t="previewAction")

    slot(name="actions")
  suggestion-list(:query="query" :loading="fetchingMentions" :mentionable="mentionable" :positionStyles="suggestionListStyles" :navigatedUserIndex="navigatedUserIndex" showUsername @select-user="selectUser")

  files-list(:files="files" v-on:removeFile="removeFile")

  form(style="display: block" @change="fileSelected")
    input.d-none(ref="filesField" type="file" name="files" multiple=true)
</template>
