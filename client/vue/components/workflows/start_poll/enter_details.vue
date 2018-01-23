<template>
  <div class="poll-form--enter-details">
    ENTER DETAILS!
  </div>
</template>

<script lang="coffee">
  EventBus = require 'shared/services/event_bus.coffee'
  Vue      = require 'vue'

  module.exports = Vue.component 'enter-details',
    props: ['poll']
    methods:
      submitDetails: (title, details) ->
        this.poll.title   = title
        this.poll.details = details
        EventBus.emit this, 'nextStep'
</script>
