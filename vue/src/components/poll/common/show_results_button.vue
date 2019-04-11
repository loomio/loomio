<script lang="coffee">
import EventBus from '@/shared/services/event_bus'

export default
  data: ->
    clicked: false

  methods:
    press: ->
      EventBus.$emit 'showResults'
      @clicked = true
</script>

<template lang="pug">
v-btn.show-results-button(flat color="accent", v-if='!clicked', @click='press()', v-t="'poll_common_card.show_results'")
</template>
