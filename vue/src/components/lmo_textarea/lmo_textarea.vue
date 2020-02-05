<script lang="coffee">
import Records from '@/shared/services/records'
import FilesList from './files_list.vue'
import EventBus  from '@/shared/services/event_bus'

import HtmlEditor from './html_editor'
import MdEditor from './md_editor'

export default
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
    'html-editor': HtmlEditor
    'md-editor': MdEditor

  data: ->
    files: []
    imageFiles: []

  computed:
    format: ->
      @model["#{@field}Format"]

</script>

<template lang="pug">
div
  label.caption.v-label.v-label--active.theme--light {{label}}

  .editor.mb-3
    html-editor(v-if="format == 'html'" :model='model' :field='field' :placeholder="placeholder" :maxLength="maxLength" :autoFocus="autoFocus")
      template(v-for="(_, name) in $scopedSlots" :slot="name" slot-scope="slotData")
        slot(:name="name" v-bind="slotData")
    md-editor(v-if="format == 'md'" :model='model' :field='field' :placeholder="placeholder" :maxLength="maxLength" :autoFocus="autoFocus")
      template(v-for="(_, name) in $scopedSlots" :slot="name" slot-scope="slotData")
        slot(:name="name" v-bind="slotData")

</template>
