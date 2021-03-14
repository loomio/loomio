<script lang="coffee">
import EventBus from '@/shared/services/event_bus'
import RescueUnsavedEditsService from '@/shared/services/rescue_unsaved_edits_service'

export default
  props:
    close: Function
    model: Object
  methods:
    closeModal: ->
      if !@model || RescueUnsavedEditsService.okToLeave(@model)
        if @close then @close() else EventBus.$emit('closeModal')

</script>

<template lang="pug">
v-btn.dismiss-modal-button(icon :aria-label="$t('common.action.cancel')" @click='closeModal')
  v-icon mdi-close
</template>
