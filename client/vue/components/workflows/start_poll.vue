<template>
  <div class="start-poll">
    <enter-type    :poll="poll" v-if="this.enterTypeStep()"></enter-type>
    <enter-details :poll="poll" v-if="this.enterDetailsStep()"></enter-details>
    <enter-options :poll="poll" v-if="this.enterOptionsStep()"></enter-options>
    {{this.currentStep}}
  </div>
</template>

<script lang="coffee">
  Vue     = require 'vue'
  Records = require 'shared/services/records.coffee'

  { applySequence } = require 'shared/helpers/apply.coffee'

  module.exports = Vue.component 'start-poll',
    created: ->
      this.poll = Records.polls.build()
      applySequence this,
        steps: ['enterType', 'enterDetails', 'enterOptions']
    methods:
      enterTypeStep:    -> this.currentStep == 'enterType'
      enterDetailsStep: -> this.currentStep == 'enterDetails'
      enterOptionsStep: -> this.currentStep == 'enterOptions'
</script>

<style scoped>
  .start-poll {
    border: 1px solid red;
  }
</style>
