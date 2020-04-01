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
    maxLength: Number
    autofocus: Boolean
    shouldReset: Boolean

  components:
    'html-editor': HtmlEditor
    'md-editor': MdEditor

  computed:
    format: ->
      @model["#{@field}Format"]


</script>

<template lang="pug">
div
  label.caption.v-label.v-label--active {{label}}

  .lmo-textarea.mb-3
    html-editor(v-if="format == 'html'" :model='model' :field='field' :placeholder="placeholder" :maxLength="maxLength" :autofocus="autofocus" :shouldReset="shouldReset")
      template(v-for="(_, name) in $scopedSlots" :slot="name" slot-scope="slotData")
        slot(:name="name" v-bind="slotData")
    md-editor(v-if="format == 'md'" :model='model' :field='field' :placeholder="placeholder" :maxLength="maxLength" :autofocus="autofocus" :shouldReset="shouldReset")
      template(v-for="(_, name) in $scopedSlots" :slot="name" slot-scope="slotData")
        slot(:name="name" v-bind="slotData")

</template>
