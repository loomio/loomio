<script lang="coffee">
import Records from '@/shared/services/records'
import Session from '@/shared/services/session'
import FilesList from './files_list.vue'
import EventBus  from '@/shared/services/event_bus'

import CollabEditor from './collab_editor'
import MdEditor from './md_editor'
import RescueUnsavedEditsService from '@/shared/services/rescue_unsaved_edits_service'

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
    'md-editor': MdEditor
    'collab-editor': CollabEditor

  mounted: ->
    RescueUnsavedEditsService.add(@model)

  computed:
    format: ->
      @model["#{@field}Format"]

</script>

<template lang="pug">
div
  label.caption.v-label.v-label--active(style="color: var(--text-secondary)" aria-hidden="true") {{label}}
  .lmo-textarea.pb-1
    collab-editor(v-if="format == 'html'" :model='model' :field='field' :placeholder="placeholder" :maxLength="maxLength" :autofocus="autofocus" :shouldReset="shouldReset")
      template(v-for="(_, name) in $scopedSlots" :slot="name" slot-scope="slotData")
        slot(:name="name" v-bind="slotData")
    md-editor(v-if="format == 'md'" :model='model' :field='field' :placeholder="placeholder" :maxLength="maxLength" :autofocus="autofocus" :shouldReset="shouldReset")
      template(v-for="(_, name) in $scopedSlots" :slot="name" slot-scope="slotData")
        slot(:name="name" v-bind="slotData")

</template>
