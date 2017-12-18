<template>
  <div class="test-vue">
    Hello {{target}}!
  </div>
</template>

<script lang="coffee">
  module.exports =
    data: ->
      target: "World"
</script>

<style scoped>
  .test-vue {
    border: 1px solid red;
  }
</style>
