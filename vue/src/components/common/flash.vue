<script lang="coffee">
import EventBus from '@/shared/services/event_bus'

export default
  data: ->
    flash: {}
    isOpen: false
    timeout: 6000
    message: ''
    options: {}
  created: ->
    EventBus.$on 'flashMessage', (flash) =>
      @flash = flash
      @isOpen = true
</script>

<template lang="pug">
v-snackbar.flash-root(v-model="isOpen" :timeout="timeout" top)
  span.flash-root__message(v-t="{path: flash.message, args: flash.options}")
</template>
