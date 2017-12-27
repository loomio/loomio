<template>
  <div class="poll-form">
    <div class="poll-form--loading" v-if="!poll">
      Loading...
    </div>
    <div class="poll-form--loaded" v-if="poll">
      <md-input-container>
        <label>Title</label>
        <md-input v-model="poll.title"></md-input>
      </md-input-container>
      <md-input-container>
        <label>Details</label>
        <md-textarea v-model="poll.details"></md-textarea>
      </md-input-container>
    </div>
  </div>
</template>

<script lang="coffee">
  Records = require 'shared/services/records.coffee'
  Vue     = require 'vue'

  module.exports = Vue.component 'poll-form',
    props: ['pollkey']
    created: ->
      if this.pollkey
        Records.polls.findOrFetchById(this.pollkey).then (poll) =>
          this.poll = poll
          this.$forceUpdate()
      else
        this.poll = Records.polls.build(pollType)
      Records.polls.findOrFetchById(this.pollkey).then (poll) =>
        this.poll = poll
        this.$forceUpdate()
</script>

<style scoped>
  .poll-form {
    border: 1px solid red;
  }
</style>
