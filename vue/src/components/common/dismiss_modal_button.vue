<script lang="coffee">
import EventBus from '@/shared/services/event_bus'
export default
  props:
    close: Function
  methods:
    closeModal: ->
      if @close then @close() else EventBus.$emit('closeModal')

</script>

<template lang="pug">
v-btn.dismiss-modal-button(icon :aria-label="$t('common.action.cancel')" @click='closeModal()')
  v-icon mdi-window-close
</template>
