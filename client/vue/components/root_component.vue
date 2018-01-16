<template>

  <start-poll></start-poll>
</template>

<script lang="coffee">
  Vue = require 'vue'

  module.exports = Vue.component 'root-component',
    data: ->
      workflow: "start_poll"
</script>
