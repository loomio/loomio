<script lang="coffee">
import { convertToHtml } from '@/shared/services/format_converter'
import { CommonMentioning, MdMentioning } from './mentioning.coffee'
import Records from '@/shared/services/records'
import FilesList from './files_list.vue'
import SuggestionList from './suggestion_list'
import Attaching from './attaching.coffee'

export default
  mixins: [CommonMentioning, MdMentioning, Attaching]
  props:
    model: Object
    field: String
    label: String
    placeholder: String
    shouldReset: Boolean
    maxLength: Number
    autoFocus:
      type: Boolean
      default: false

  components:
    FilesList: FilesList
    SuggestionList: SuggestionList

  data: ->
    preview: false

  methods:
    convertToHtml: ->
      convertToHtml(@model, @field)
      Records.users.removeExperience('html-editor.uses-markdown')

  computed:
    previewAction: ->
      if @preview then 'common.action.edit' else 'common.action.preview'
    previewIcon: ->
      if @preview then 'mdi-pencil' else 'mdi-eye'
</script>

<template lang="pug">
div(style="position: relative")
  v-textarea(v-if="!preview" v-model="model[field]" @keyup="onKeyUp" @keydown="onKeyDown" ref="field")
  formatted-text(v-if="preview" :model="model" :column="field")
  v-sheet.pa-4.my-4.poll-common-outcome-panel(v-if="preview && model[field].trim().length == 0" color="primary lighten-5" elevation="2")
    p No content to preview

  v-layout(align-center)
    v-btn(icon @click='$refs.filesField.click()' :title="$t('formatting.attach')")
      v-icon mdi-paperclip
    v-btn(text x-small @click="convertToHtml(model, field)" v-t="'formatting.use_wysiwyg'")
    v-btn(text x-small href="/markdown" target="_blank" v-t="'formatting.markdown_help'")
    v-spacer
    v-btn.mr-4(text @click="preview = !preview" v-t="previewAction")

    slot(name="actions")
  suggestion-list(:query="query" :filtered-users="filteredUsers" :positionStyles="suggestionListStyles" :navigatedUserIndex="navigatedUserIndex" showUsername)

  files-list(:files="files" v-on:removeFile="removeFile")

  form(style="display: block" @change="fileSelected")
    input(ref="filesField" type="file" name="files" multiple=true)
</template>
