<script lang="coffee">
import { convertToHtml } from '@/shared/services/format_converter'
import { CommonMentioning, MdMentioning } from './mentioning.coffee'
import Records from '@/shared/services/records'
import FilesList from './files_list.vue'
import SuggestionList from './suggestion_list'
import Attaching from './attaching.coffee'
import {escapeRegExp} from 'lodash'

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

    onPaste: (event) ->
      items = Array.from(event.clipboardData.items)

      return if items.filter((item) => item.getAsFile()).length == 0

      event.preventDefault()
      files = items.map (item) =>
        new File([item.getAsFile()],
                 event.clipboardData.getData('text/plain') || Date.now(),
                 {lastModified: Date.now(), type: item.type})

    handleUploads: (files) ->
      console.log 'hande uploads', files
      Array.from(files).forEach (file) =>
        if ((/image/i).test(file.type))
          @insertImage(file)
        else
          @attachFile({file: file})

    insertImage: (file) ->
      beforeText = @model[@field].slice(0, @textarea().selectionStart)
      afterText = @model[@field].slice(@textarea().selectionStart)
      name = file.name.replace(/[\W_]+/g, '') | 'file';
      uploadingText = (pct) -> " ![uploading-#{name}](#{pct}%) "
      @model[@field] = beforeText + uploadingText(0) + afterText
      regex = ///!\[uploading-#{name}\]\(\d+%\)///

      @attachImageFile
        file: file
        onProgress: (e) =>
          pct = parseInt(e.loaded / e.total * 100)
          @model[@field] = @model[@field].replace(regex, uploadingText(pct))

        onComplete: (blob) =>
          @model[@field] = @model[@field].replace(regex, "![#{name}](#{blob.preview_url})")

        onFailure: () =>
          # @model[@field].replace(regex, '')

    onDrop: (event) ->
      console.log 'drop', event
      return unless event.dataTransfer && event.dataTransfer.files && event.dataTransfer.files.length
      event.preventDefault()
      @handleUploads(event.dataTransfer.files)

    onDragOver: (event) ->
      false


  computed:
    previewAction: ->
      if @preview then 'common.action.edit' else 'common.action.preview'
    previewIcon: ->
      if @preview then 'mdi-pencil' else 'mdi-eye'

</script>

<template lang="pug">
div(style="position: relative")
  v-textarea(v-if="!preview" ref="field" v-model="model[field]" @keyup="onKeyUp" @keydown="onKeyDown" @paste="onPaste" @drop="onDrop" @dragover.prevent="onDragOver")
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
