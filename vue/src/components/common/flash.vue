<script lang="coffee">
import EventBus from '@/shared/services/event_bus'

export default
  data: ->
    flash: {}
    isOpen: false
    message: ''
    seconds: 0
    timer: null
  created: ->
    EventBus.$on 'flashMessage', (flash) =>
      @flash = flash
      @isOpen = true
      @timer = window.setInterval =>
        @seconds += 3
      , 1000
  destroyed: ->
    clearInterval(timer)

</script>

<template lang="pug">
v-snackbar.flash-root(:color="flash.level == 'success' ? 'primary' : flash.level" v-model="isOpen" :timeout="flash.duration" top)
  span.flash-root__message(role="status" aria-live="assertive" v-t="{path: flash.message, args: flash.options}")
  v-progress-linear.mt-2(v-if="flash.level == 'wait'" :value="seconds")
  .flash-root__action(v-if="flash.actionFn")
    a(@click="flash.actionFn()", v-t="flash.action")
</template>
