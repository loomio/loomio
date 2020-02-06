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
    autofocus:
      type: Boolean
      default: false

  components:
    FilesList: FilesList
    SuggestionList: SuggestionList

  data: ->
    preview: false

  methods:
    reset: -> true
    convertToHtml: ->
      convertToHtml(@model, @field)
      Records.users.removeExperience('html-editor.uses-markdown')

    onPaste: (event) ->
      items = Array.from(event.clipboardData.items)

      return if items.filter((item) => item.getAsFile()).length == 0

      event.preventDefault()
      @handleUploads items.map (item) =>
        new File([item.getAsFile()],
                 event.clipboardData.getData('text/plain') || Date.now(),
                 {lastModified: Date.now(), type: item.type})

    handleUploads: (files) ->
      Array.from(files).forEach (file) =>
        if ((/image/i).test(file.type))
          @insertImage(file)
        else
          @attachFile({file: file})

    insertImage: (file) ->
      name = file.name.replace(/[\W_]+/g, '') | 'file';

      uploadingText = (pct) ->
        "![uploading-#{name}](#{"*".repeat parseInt(pct / 5)})"

      insertPlaceholder = (text) =>
        beforeText = @model[@field].slice(0, @textarea().selectionStart)
        afterText = @model[@field].slice(@textarea().selectionStart)
        @model[@field] = beforeText + "\n" + text + "\n" + afterText

      updatePlaceholder = (text) =>
        @model[@field] = @model[@field].replace(///!\[uploading-#{name}\]\(\**\)///, text)

      insertPlaceholder(uploadingText(0))

      @attachImageFile
        file: file
        onProgress: (e) =>
          updatePlaceholder(uploadingText(parseInt(e.loaded / e.total * 100)))

        onComplete: (blob) =>
          updatePlaceholder("![#{name}](#{blob.preview_url})")

        onFailure: () =>
          updatePlaceholder("![#{name}](#{@$t('formatting.upload_failed')}")

    onDrop: (event) ->
      return unless event.dataTransfer && event.dataTransfer.files && event.dataTransfer.files.length
      event.preventDefault()
      @handleUploads(event.dataTransfer.files)

    onDragOver: (event) -> false

  computed:
    previewAction: ->
      if @preview then 'common.action.edit' else 'common.action.preview'
    previewIcon: ->
      if @preview then 'mdi-pencil' else 'mdi-eye'

</script>

<template lang="pug">
div(style="position: relative")
  v-textarea(v-if="!preview" ref="field" v-model="model[field]" :placeholder="placeholder" @paste="onPaste" @drop="onDrop" @dragover.prevent="onDragOver")
  formatted-text(v-if="preview" :model="model" :column="field")
  v-sheet.pa-4.my-4.poll-common-outcome-panel(v-if="preview && model[field].trim().length == 0" color="primary lighten-5" elevation="2")
    p(v-t="'common.empty'")

  v-layout.menubar(align-center)
    v-btn(icon @click='$refs.filesField.click()' :title="$t('formatting.attach')")
      v-icon mdi-paperclip
    v-btn(text x-small @click="convertToHtml(model, field)" v-t="'formatting.wysiwyg'")
    v-spacer
    //- v-btn(text href="/markdown" target="_blank" v-t="'common.help'")
    v-btn.mr-4(text x-small @click="preview = !preview" v-t="previewAction")

    slot(name="actions")
  suggestion-list(:query="query" :filtered-users="filteredUsers" :positionStyles="suggestionListStyles" :navigatedUserIndex="navigatedUserIndex" showUsername)

  files-list(:files="files" v-on:removeFile="removeFile")

  form(style="display: block" @change="fileSelected")
    input(ref="filesField" type="file" name="files" multiple=true)
</template>
