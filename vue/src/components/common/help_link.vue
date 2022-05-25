<script lang="coffee">
export default
  props:
    text: String
    path: String
</script>

<template lang="pug">
.help-link.d-flex.align-center
  v-icon.mr-2 mdi-book-open-variant
  a(:href="'https://help.loomio.com/'+path"
    v-t="text"
    target="_blank")
</template>

<style lang="sass">
.help-link
  a
    color: rgba(0, 0, 0, 0.6)

.theme--dark .help-link
  a
    color: rgba(255, 255, 255, 0.7)
</style>