<script lang="coffee">
EventBus = require 'shared/services/event_bus'

module.exports =
  data: ->
    clicked: false

  methods:
    press: ->
      EventBus.$emit @, 'showResults'
      @clicked = true
</script>

<template lang="pug">
v-btn.show-results-button(flat color="accent", v-if='!clicked', @click='press()', v-t="'poll_common_card.show_results'")
</template>
