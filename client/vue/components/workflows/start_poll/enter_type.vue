<template>
  <div class="poll-form--select-type">
    <div class="poll-form--select-type-button" v-for="pollType in pollTypes">
      <button type="button" v-on:click="selectType(pollType)">{{pollType}}</button>
    </div>
  </div>
</template>

<script lang="coffee">
  EventBus = require 'shared/services/event_bus.coffee'
  Vue      = require 'vue'

  module.exports = Vue.component 'enter-type',
    props: ['poll']
    created: ->
      this.pollTypes = [
        'proposal',
        'check',
        'poll',
        'dot_vote',
        'meeting',
        'ranked_choice'
      ]
    methods:
      selectType: (pollType) ->
        this.poll.pollType = pollType
        console.log("emitting #{pollType}...")
        EventBus.emit this, 'nextStep', pollType
</script>
