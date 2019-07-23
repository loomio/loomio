<script lang="coffee">
import EventBus from '@/shared/services/event_bus'
export default
  methods:
    close: -> EventBus.$emit('closeModal')
</script>

<template lang="pug">
v-btn.dismiss-modal-button(icon small :aria-label="$t('common.action.cancel')" @click='close()')
  v-icon mdi-window-close
</template>
