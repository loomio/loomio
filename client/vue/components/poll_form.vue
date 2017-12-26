<template>
  <div class="poll-form">
    <md-field>
      <label>Initial Value</label>
      <md-input v-model="poll.title"></md-input>
    </md-field>
    <md-field>
      <label>Initial Value</label>
      <md-textarea v-model="poll.details"></md-input>
    </md-field>
  </div>
</template>

<script lang="coffee">
  Records = require 'shared/services/records.coffee'

  module.exports =
    props: ['poll']
    created: ->
      Records.polls.findOrFetchById("ofsKRbUV").then (poll) =>
        this.poll = poll
</script>

<style scoped lang="scss">
  .poll-form {
    border: 1px solid red;
  }
</style>
