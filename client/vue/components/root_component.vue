<template>
  <div class="test-vue">Hello {{target}}!</div>
</template>

<script lang="coffee">
  Records = require 'shared/services/records.coffee'

  module.exports =
    created: ->
      this.poll = Records.polls.build(title: "Loading...")
      Records.polls.findOrFetchById("JUPYVnBD").then (poll) => this.poll = poll
    data: ->
      target: this.poll.title
</script>

<style scoped lang="scss">
  .test-vue {
    border: 1px solid red;
  }
</style>
