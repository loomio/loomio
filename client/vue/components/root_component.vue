<template>
  <poll-form :pollkey="key"></poll-form>
</template>

<script lang="coffee">
  Vue = require 'vue'

  module.exports = Vue.component 'root-component',
    data: ->
      key: "CjXsIEBQ"
</script>
